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
 * Returns FCM tokens of the group members who accept reading notifications
 * (notifyOnMemberProgress not false), excluding the one who read.
 * @param {string} groupId - The Firestore group document ID.
 * @param {string} [excludeUserId] - UID to exclude from the result.
 */
async function getProgressRecipientTokens(
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
    if (doc.data().notifyOnMemberProgress === false) continue;
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
    // Rattrapage d'un nouveau membre : pas de notification par jour.
    if (progress.catchUp === true) return;

    const groupSnap = await db.doc(`groups/${groupId}`).get();
    const groupName = groupSnap.data()?.name as string | undefined;
    if (!groupName) return;

    // Une seule notification par jour lu : décocher puis recocher
    // recrée le doc de progression mais ne renvoie rien.
    const memberRef = db.doc(`groups/${groupId}/members/${userId}`);
    const firstTime = await db.runTransaction(async (tx) => {
      const member = await tx.get(memberRef);
      if (!member.exists) return false;
      const notified = (member.data()?.notifiedDays ?? []) as number[];
      if (notified.includes(dayIndex)) return false;
      tx.update(memberRef, {
        notifiedDays: admin.firestore.FieldValue.arrayUnion(dayIndex),
      });
      return true;
    });
    if (!firstTime) return;

    const tokens = await getProgressRecipientTokens(groupId, userId);
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
 * Daily reminder at 19:00 UTC for group members who haven't read
 * today's day of the plan (not just "checked something today").
 */
export const scheduledGroupReminder = onSchedule(
  {schedule: "0 19 * * *", timeZone: "UTC"},
  async () => {
    // Snapshot dates are the host's local dates ("2026-11-08T00:00:00.000").
    // shortcut: compares with today's UTC date, right for UTC-5…UTC+4 at
    // 19:00 UTC; use each group's timezone if users go beyond that.
    const today = new Date().toISOString().slice(0, 10);

    const groupsSnap = await db
      .collection("groups")
      .where("status", "==", "active")
      .get();

    for (const groupDoc of groupsSnap.docs) {
      const groupId = groupDoc.id;
      const groupName = groupDoc.data().name as string;
      const snapshot = (groupDoc.data().planSnapshot ?? []) as
        {d: number; dt: string}[];
      const todayDay = snapshot.find((day) => day.dt.slice(0, 10) === today);
      if (!todayDay) continue; // pas de lecture prévue aujourd'hui

      const progressSnap = await db
        .collection(`groups/${groupId}/progress`)
        .where("dayIndex", "==", todayDay.d)
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
        data: {groupId},
        android: {priority: "normal"},
      });
    }
  },
);
