import * as admin from "firebase-admin";
import {setGlobalOptions} from "firebase-functions";
import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {onSchedule} from "firebase-functions/v2/scheduler";

admin.initializeApp();
setGlobalOptions({maxInstances: 10, region: "europe-west1"});

const db = admin.firestore();
const fcm = admin.messaging();

// ── Helpers ────────────────────────────────────────────────────

/**
 * Returns the FCM token for a given user, or null if not set.
 * @param {string} userId - The Firebase Auth UID.
 */
async function getToken(userId: string): Promise<string | null> {
  const snap = await db.doc(`users/${userId}`).get();
  return snap.data()?.fcmToken ?? null;
}

/**
 * Returns FCM tokens for all members of a group,
 * optionally excluding one user (e.g. the one who triggered the event).
 * @param {string} groupId - The Firestore group document ID.
 * @param {string} [excludeUserId] - UID to exclude from the result.
 */
async function getMemberTokens(
  groupId: string,
  excludeUserId?: string,
): Promise<string[]> {
  const snap = await db
    .collection(`groups/${groupId}/members`)
    .get();
  const tokens: string[] = [];
  for (const doc of snap.docs) {
    const uid = doc.data().userId as string;
    if (uid === excludeUserId) continue;
    const token = await getToken(uid);
    if (token) tokens.push(token);
  }
  return tokens;
}

// ── onGroupCreate ──────────────────────────────────────────────

/**
 * Notifies the group host when the group document is first created.
 */
export const onGroupCreate = onDocumentCreated(
  "groups/{groupId}",
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    const {hostId, name} = data as {hostId: string; name: string};
    const token = await getToken(hostId);
    if (!token) return;

    await fcm.send({
      token,
      notification: {
        title: "Groupe créé",
        body: `"${name}" est prêt. Partagez le code d'invitation !`,
      },
      data: {groupId: event.params.groupId},
      android: {priority: "normal"},
    });
  },
);

// ── onMemberJoin ───────────────────────────────────────────────

/**
 * Notifies the host when a new member joins the group.
 * Ignores the host's own member document created at group creation.
 */
export const onMemberJoin = onDocumentCreated(
  "groups/{groupId}/members/{memberId}",
  async (event) => {
    const member = event.data?.data();
    if (!member) return;

    if (member.role === "host") return;

    const {groupId} = event.params;
    const groupSnap = await db.doc(`groups/${groupId}`).get();
    const group = groupSnap.data();
    if (!group) return;

    const hostToken = await getToken(group.hostId);
    if (!hostToken) return;

    await fcm.send({
      token: hostToken,
      notification: {
        title: group.name,
        body: `${member.displayName} a rejoint le groupe !`,
      },
      data: {groupId},
      android: {priority: "normal"},
    });
  },
);

// ── onProgressCreate ───────────────────────────────────────────

/**
 * Notifies other group members when someone marks a reading day complete.
 */
export const onProgressCreate = onDocumentCreated(
  "groups/{groupId}/progress/{progressId}",
  async (event) => {
    const progress = event.data?.data();
    if (!progress) return;

    const {groupId} = event.params;
    const {userId, displayName, dayIndex} = progress as {
      userId: string;
      displayName: string;
      dayIndex: number;
    };

    const groupSnap = await db.doc(`groups/${groupId}`).get();
    const groupName = groupSnap.data()?.name as string | undefined;
    if (!groupName) return;

    const tokens = await getMemberTokens(groupId, userId);
    if (tokens.length === 0) return;

    await fcm.sendEachForMulticast({
      tokens,
      notification: {
        title: groupName,
        body: `${displayName} a lu le jour ${dayIndex + 1} ✓`,
      },
      data: {groupId},
      android: {priority: "normal"},
    });
  },
);

// ── scheduledGroupReminder ─────────────────────────────────────

/**
 * Daily reminder at 19:00 UTC for group members who haven't read yet.
 */
export const scheduledGroupReminder = onSchedule(
  {schedule: "0 19 * * *", timeZone: "UTC"},
  async () => {
    const now = new Date();
    const y = now.getFullYear();
    const m = now.getMonth();
    const d = now.getDate();
    const start = new Date(y, m, d, 0, 0, 0);
    const end = new Date(y, m, d, 23, 59, 59);

    const groupsSnap = await db
      .collection("groups")
      .where("status", "==", "active")
      .get();

    for (const groupDoc of groupsSnap.docs) {
      const groupId = groupDoc.id;
      const groupName = groupDoc.data().name as string;

      const progressSnap = await db
        .collection(`groups/${groupId}/progress`)
        .where("completedAt", ">=", start)
        .where("completedAt", "<=", end)
        .get();

      const readToday = new Set(
        progressSnap.docs.map((doc) => doc.data().userId as string),
      );

      const membersSnap = await db
        .collection(`groups/${groupId}/members`)
        .get();

      const tokens: string[] = [];
      for (const doc of membersSnap.docs) {
        const uid = doc.data().userId as string;
        if (readToday.has(uid)) continue;
        const token = await getToken(uid);
        if (token) tokens.push(token);
      }

      if (tokens.length === 0) continue;

      await fcm.sendEachForMulticast({
        tokens,
        notification: {
          title: groupName,
          body: "Avez-vous lu votre portion d'aujourd'hui ? 📖",
        },
        android: {priority: "normal"},
      });
    }
  },
);
