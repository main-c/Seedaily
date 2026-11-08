// Tests des règles Firestore sur l'émulateur.
// Lancer depuis functions/ : npm run test:rules
import {test, before, beforeEach, after} from "node:test";
import {readFileSync} from "node:fs";
import {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} from "@firebase/rules-unit-testing";
import {
  doc, getDoc, setDoc, updateDoc, deleteDoc, collection, collectionGroup, getDocs, query, where,
  writeBatch,
} from "firebase/firestore";

const GROUP = "g1";
const CODE = "ABC234";
let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: "demo-seedaily",
    firestore: {rules: readFileSync("../firestore.rules", "utf8")},
  });
});

after(() => env.cleanup());

// Chaque test part d'un groupe créé par "host" via les règles, comme l'app.
beforeEach(async () => {
  await env.clearFirestore();
  const db = env.authenticatedContext("host").firestore();
  const batch = writeBatch(db);
  batch.set(doc(db, "groups", GROUP), {
    hostId: "host", name: "G", inviteCode: CODE, status: "active",
  });
  batch.set(doc(db, "inviteCodes", CODE), {groupId: GROUP});
  batch.set(doc(db, "groups", GROUP, "members", "host"), {
    userId: "host", role: "host",
  });
  await assertSucceeds(batch.commit());
});

const as = (uid) => env.authenticatedContext(uid).firestore();
const join = (db, uid, code = CODE) =>
  setDoc(doc(db, "groups", GROUP, "members", uid), {
    userId: uid, role: "member", inviteCode: code,
  });

test("rejoindre avec le bon code, puis lire le groupe", async () => {
  const db = as("alice");
  const codeDoc = await assertSucceeds(getDoc(doc(db, "inviteCodes", CODE)));
  const groupId = codeDoc.data().groupId;
  await assertSucceeds(getDoc(doc(db, "groups", groupId, "members", "alice")));
  await assertSucceeds(join(db, "alice"));
  await assertSucceeds(getDoc(doc(db, "groups", groupId)));
});

test("impossible de lister les groupes ou les codes", async () => {
  const db = as("eve");
  await assertFails(getDocs(collection(db, "groups")));
  await assertFails(getDocs(collection(db, "inviteCodes")));
  await assertFails(getDoc(doc(db, "groups", GROUP)));
});

test("impossible de rejoindre sans le bon code ou en se disant hôte", async () => {
  const db = as("eve");
  await assertFails(join(db, "eve", "WRONG1"));
  await assertFails(setDoc(doc(db, "groups", GROUP, "members", "eve"), {
    userId: "eve", role: "host",
  }));
});

test("un code déjà pris ne peut pas être réutilisé", async () => {
  const db = as("bob");
  const batch = writeBatch(db);
  batch.set(doc(db, "groups", "g2"), {hostId: "bob", inviteCode: CODE});
  batch.set(doc(db, "inviteCodes", CODE), {groupId: "g2"});
  await assertFails(batch.commit());
});

test("cocher deux fois le même jour, mais pas sans être membre", async () => {
  const db = as("alice");
  await join(db, "alice");
  const day = doc(db, "groups", GROUP, "progress", "alice_0");
  await assertSucceeds(setDoc(day, {userId: "alice", dayIndex: 0}));
  await assertSucceeds(setDoc(day, {userId: "alice", dayIndex: 0}));
  await assertSucceeds(getDocs(query(
    collection(db, "groups", GROUP, "progress"),
    where("userId", "==", "alice"))));

  const eve = as("eve");
  await assertFails(setDoc(doc(eve, "groups", GROUP, "progress", "eve_0"),
    {userId: "eve", dayIndex: 0}));
});

test("liste de mes groupes via collectionGroup", async () => {
  const db = as("alice");
  await join(db, "alice");
  await assertSucceeds(getDocs(query(
    collectionGroup(db, "members"), where("userId", "==", "alice"))));
  await assertSucceeds(getDoc(doc(db, "groups", GROUP)));
});

test("l'hôte supprime un groupe qui a des membres", async () => {
  await join(as("alice"), "alice");
  await setDoc(doc(as("alice"), "groups", GROUP, "progress", "alice_0"),
    {userId: "alice", dayIndex: 0});

  const db = as("host");
  const batch = writeBatch(db);
  batch.delete(doc(db, "groups", GROUP, "members", "alice"));
  batch.delete(doc(db, "groups", GROUP, "members", "host"));
  batch.delete(doc(db, "groups", GROUP, "progress", "alice_0"));
  batch.delete(doc(db, "inviteCodes", CODE));
  batch.delete(doc(db, "groups", GROUP));
  await assertSucceeds(batch.commit());
});

test("un membre quitte, mais ne peut pas supprimer les autres", async () => {
  await join(as("alice"), "alice");
  await join(as("bob"), "bob");
  await assertFails(deleteDoc(doc(as("bob"), "groups", GROUP, "members", "alice")));
  await assertSucceeds(deleteDoc(doc(as("bob"), "groups", GROUP, "members", "bob")));
});

test("un membre coupe ses notifications, sans toucher au reste", async () => {
  await join(as("alice"), "alice");
  await join(as("bob"), "bob");
  const db = as("alice");
  const mine = doc(db, "groups", GROUP, "members", "alice");
  await assertSucceeds(updateDoc(mine, {notifyOnMemberProgress: false}));
  await assertFails(updateDoc(mine, {role: "host"}));
  await assertFails(updateDoc(mine, {notifyOnMemberProgress: "non"}));
  await assertFails(updateDoc(doc(db, "groups", GROUP, "members", "bob"),
    {notifyOnMemberProgress: false}));
});
