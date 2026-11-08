// À lancer une seule fois après le déploiement des nouvelles règles :
// crée inviteCodes/{code} pour les groupes créés avant ce changement.
//
//   cd functions
//   GOOGLE_APPLICATION_CREDENTIALS=/chemin/cle-service.json \
//     node scripts/backfill-invite-codes.mjs
import {initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";

initializeApp({projectId: "seedaily-a720c"});
const db = getFirestore();

const groups = await db.collection("groups").get();
let created = 0;
for (const g of groups.docs) {
  const code = g.get("inviteCode");
  if (!code) continue;
  const ref = db.doc(`inviteCodes/${code}`);
  if ((await ref.get()).exists) continue;
  await ref.set({groupId: g.id});
  created++;
}
console.log(`${groups.size} groupes, ${created} codes ajoutés.`);
