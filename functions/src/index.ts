import * as admin from "firebase-admin";
import {setGlobalOptions} from "firebase-functions";
import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {onSchedule} from "firebase-functions/v2/scheduler";

admin.initializeApp();
setGlobalOptions({maxInstances: 10, region: "europe-west1"});

const db = admin.firestore();
const fcm = admin.messaging();

// ── Helpers ────────────────────────────────────────────────────

type Locale = "fr" | "en";

interface Recipient {
  token: string;
  locale: Locale;
}

/**
 * Returns the FCM token and language of a user, or null if no token.
 * `users/{uid}.locale` is written by the app; missing → French.
 * @param {string} userId - The Firebase Auth UID.
 */
async function getRecipient(userId: string): Promise<Recipient | null> {
  const snap = await db.doc(`users/${userId}`).get();
  const data = snap.data();
  const token = data?.fcmToken as string | undefined;
  if (!token) return null;
  return {token, locale: data?.locale === "en" ? "en" : "fr"};
}

/**
 * Groups recipients' tokens by language.
 * @param {Recipient[]} recipients - Recipients to group.
 * @return {Map<Locale, string[]>} Tokens per language.
 */
function tokensByLocale(recipients: Recipient[]): Map<Locale, string[]> {
  const map = new Map<Locale, string[]>();
  for (const r of recipients) {
    map.set(r.locale, [...(map.get(r.locale) ?? []), r.token]);
  }
  return map;
}

/**
 * Returns recipients for all members of a group,
 * optionally excluding one user (e.g. the one who triggered the event).
 * @param {string} groupId - The Firestore group document ID.
 * @param {string} [excludeUserId] - UID to exclude from the result.
 */
async function getMemberRecipients(
  groupId: string,
  excludeUserId?: string,
): Promise<Recipient[]> {
  const snap = await db
    .collection(`groups/${groupId}/members`)
    .get();
  const recipients: Recipient[] = [];
  for (const doc of snap.docs) {
    const uid = doc.data().userId as string;
    if (uid === excludeUserId) continue;
    const recipient = await getRecipient(uid);
    if (recipient) recipients.push(recipient);
  }
  return recipients;
}

// Textes des notifications, par langue du destinataire.
const messages = {
  groupCreatedTitle: {fr: "Groupe créé", en: "Group created"},
  groupCreatedBody: {
    fr: (name: string) => `"${name}" est prêt. Partagez le code d'invitation !`,
    en: (name: string) => `"${name}" is ready. Share the invite code!`,
  },
  memberJoined: {
    fr: (name: string) => `${name} a rejoint le groupe !`,
    en: (name: string) => `${name} joined the group!`,
  },
  progress: {
    fr: (name: string, day: number) => `${name} a lu le jour ${day} ✓`,
    en: (name: string, day: number) => `${name} read day ${day} ✓`,
  },
  reminder: {
    fr: "Avez-vous lu votre portion d'aujourd'hui ? 📖",
    en: "Have you read today's portion? 📖",
  },
};

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
    const host = await getRecipient(hostId);
    if (!host) return;

    await fcm.send({
      token: host.token,
      notification: {
        title: messages.groupCreatedTitle[host.locale],
        body: messages.groupCreatedBody[host.locale](name),
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

    const host = await getRecipient(group.hostId);
    if (!host) return;

    await fcm.send({
      token: host.token,
      notification: {
        title: group.name,
        body: messages.memberJoined[host.locale](member.displayName),
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

    const recipients = await getMemberRecipients(groupId, userId);
    for (const [locale, tokens] of tokensByLocale(recipients)) {
      await fcm.sendEachForMulticast({
        tokens,
        notification: {
          title: groupName,
          body: messages.progress[locale](displayName, dayIndex + 1),
        },
        data: {groupId},
        android: {priority: "normal"},
      });
    }
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

      const recipients: Recipient[] = [];
      for (const doc of membersSnap.docs) {
        const uid = doc.data().userId as string;
        if (readToday.has(uid)) continue;
        const recipient = await getRecipient(uid);
        if (recipient) recipients.push(recipient);
      }

      for (const [locale, tokens] of tokensByLocale(recipients)) {
        await fcm.sendEachForMulticast({
          tokens,
          notification: {
            title: groupName,
            body: messages.reminder[locale],
          },
          android: {priority: "normal"},
        });
      }
    }
  },
);
