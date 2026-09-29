Plans disponibles
4 plans structurés (structure fixe, seule la date de début est modifiable)

M'Cheyne — lecture parallèle AT + NT sur 365 jours
Bible en 1 an (Ligue) — AT + Psaume + Proverbe + NT chaque jour
Plan Révolutionnaire — 25 jours de lecture par mois avec jours de repos
Plan Horner — lecture en boucle infinie sur 10 listes
5 plans thématiques (durée et rythme modifiables)

Nouveau Testament, Ancien Testament, Évangiles, Psaumes, Proverbes
2 plans personnalisés (tout est modifiable)

Lecture canonique et lecture chronologique
Personnalisation
Sélection des livres individuels (avec filtres AT/NT/Apocryphes)
Ordre de lecture : canonique, chronologique, juif, inversé
Psaumes quotidiens : aucun / un par jour / séquentiel
Proverbes quotidiens : aucun / un par jour / selon le jour du mois
Chevauchement AT/NT : séquentiel ou alterné
Distribution : équilibrée, progressive, dégressive
Date de début personnalisée
Durée totale personnalisée
Jours de lecture sélectionnables (Lun–Dim)
Vues de lecture
Vue liste — défilement vertical de tous les jours
Vue calendrier — calendrier mensuel avec navigation
Vue hebdomadaire — jours groupés par semaine avec image de fond
Vue par livre — regroupement par livre biblique
Suivi de progression
Cases à cocher par jour de lecture
Pourcentage de complétion
Streak (jours consécutifs)
Statut : en avance / dans les temps / en retard / terminé
Filtres sur l'accueil : Tous / En cours / Terminés
Paramètres
Thème : clair / sombre / système
Notifications : activez/désactivez + heure personnalisable
Mode prévisualisation pour les plans avant création
Export & partage
Export PDF avec code couleur par genre biblique (Loi, Histoire, Sagesse, Prophètes, NT)
Options d'export : statistiques incluses ou non, cases à cocher ou non
Partage via le système natif
Gestion des plans
Créer, modifier, supprimer un plan
Réinitialiser la progression d'un plan
Édition en place (préserve les jours déjà complétés)
Technique (invisible utilisateur)
Stockage 100% local (Hive, aucune donnée envoyée en dehors)
Firebase Analytics + Crashlytics en production
Splash screen + icône personnalisés
Notifications timezone-aware
commprenant desormais le purpose de l'app, quel pourrait etre les prochaine fonctionnalite de l'app, Selon toi qu'est ce qu'on peut faire pour retenir les users sur l'app et les amener a revenir sur l'app chaque jour voir mm plusieurs fois par jour
pour type d'app,
Bonne question. Pour une app de discipline spirituelle quotidienne, la rétention repose sur deux axes : l'habitude (revenir chaque jour) et l'engagement (avoir une raison de revenir plusieurs fois).

Ce qui ferait revenir chaque jour
1. Widget écran d'accueil (impact #1)
Le passage du jour directement sur l'écran sans ouvrir l'app. Sur Android c'est faisable avec home_widget. C'est le raccourci le plus puissant pour une app de lecture quotidienne — les apps Bible App, YouVersion, etc. reposent massivement là-dessus.

2. Notifications enrichies
Plutôt qu'un simple "C'est l'heure de lire", envoyer directement le premier verset du jour dans la notification. L'utilisateur voit du contenu sans ouvrir l'app, ce qui paradoxalement l'incite à l'ouvrir pour lire la suite.

3. Streak plus gamifié
Le streak existe déjà mais est discret. Le rendre central : animation de feu quand on maintient son streak, record personnel, compteur visible sur la home. La peur de casser son streak est un moteur psychologique puissant (Duolingo en a fait sa colonne vertébrale).

4. Verset du jour (indépendant du plan)
Un verset affiché chaque matin, indépendant du plan de lecture. Ça donne une raison d'ouvrir l'app même les jours sans lecture (jours de repos dans certains plans).

Ce qui ferait revenir plusieurs fois par jour
5. Journal / Notes de réflexion
Permettre d'ajouter une note courte après la lecture. Les gens reviennent pour relire leurs notes, les compléter le soir, ou les partager. C'est un contenu qu'ils ont créé dans l'app — très fort pour l'attachement.

6. Mode "Méditation du soir"
Un rappel du soir (configurable) qui affiche un résumé de ce qu'ils ont lu le matin : "Vous avez lu Matthieu 5-6 ce matin. Un verset à méditer ce soir : Matt 5:3". Deux points de contact par jour sur le même contenu.

7. Statistiques enrichies
Graphes de progression semaine/mois, nombre de chapitres lus, livres terminés, carte de chaleur de l'activité (comme GitHub). Les gens reviennent pour voir leurs stats évoluer — c'est le même mécanisme que les apps fitness.

Ce qui ferait rester longtemps dans l'app
8. Groupes / Lecture communautaire
Partager un plan avec des amis ou sa communauté d'église. Voir qui a complété sa lecture aujourd'hui. C'est la fonctionnalité la plus structurante pour la rétention long terme — mais aussi la plus complexe à construire (backend nécessaire).

9. Défis & Badges
"7 jours consécutifs", "1 mois sans interruption", "Nouveau Testament terminé", "Bible complète". Récompenses visibles sur le profil. Ça crée des objectifs intermédiaires et de la fierté à partager.

10. Contexte historique / notes de passage
Une courte note d'introduction pour chaque livre (qui a écrit, quand, pourquoi). Ça transforme la lecture en apprentissage, les utilisateurs restent plus longtemps par passage.

Ma recommandation de priorité
Priorité	Fonctionnalité	Effort	Impact rétention
1	Streak gamifié	Faible	Très élevé
2	Notifications enrichies	Faible	Élevé
3	Widget écran d'accueil	Moyen	Très élevé
4	Journal / Notes	Moyen	Élevé
5	Verset du jour	Faible	Moyen
6	Stats & badges	Moyen	Moyen
7	Groupes communautaires	Élevé	Très élevé (long terme)
Court terme (avant la production) : streak gamifié + notifications enrichies — ce sont des améliorations de l'existant, peu risquées et à fort impact.

Moyen terme : widget + journal de réflexion.

Long terme : groupes/communauté — ça change l'architecture (backend) mais c'est ce qui transforme une app utile en app indispensable.Groupes communautaires
-----------------------------------------------------------------------------------------

Parcours utilisateur — Lecture en groupe
1. Création d'un plan (hôte)
L'utilisateur choisit un plan dans l'onglet Découvrir (ou clique sur le FAB depuis Accueil)
Il personnalise son plan sur l'écran Personnaliser (livres, durée, rythme, etc.)
Il clique "Créer le plan"
Une modal s'ouvre avec l'illustration et le message "Deux valent mieux qu'un !"
Fourche :

"Continuer seul(e)" → plan solo sauvegardé dans Hive, retour à l'accueil
"Inviter mes amis" → continue ci-dessous
2. Chemin "Inviter mes amis"
Si pas connecté → connexion Google silencieuse déclenchée automatiquement
Le groupe est créé sur Firestore avec le titre du plan comme nom de groupe
La feuille de partage native Android/iOS s'ouvre avec le message :
"Lis la Bible avec moi sur Seedaily ! 📖
Rejoins mon plan "M'Cheyne 365" :
https://seedaily.app/join/AB3XY7"

L'utilisateur partage via WhatsApp / SMS / email / ce qu'il veut
Il est redirigé vers l'écran de détail du groupe
3. Rejoindre un groupe (invité)
L'invité reçoit le lien. Aujourd'hui le lien n'est pas encore un deep link fonctionnel — il doit aller dans l'app manuellement :

Onglet Groupe → se connecter avec Google si besoin
Icône "Rejoindre" (personne + dans l'AppBar)
Saisir le code à 6 caractères du lien (AB3XY7)
Le plan est reconstitué depuis le snapshot Firestore et sauvegardé localement
Redirection vers l'écran de détail du groupe
4. Vie quotidienne du groupe
Chaque membre voit dans l'onglet Groupe la liste de ses groupes avec la progression du plan
L'écran de détail du groupe affiche qui a lu aujourd'hui en temps réel (Firestore)
Quand un membre coche un jour dans son plan personnel → ça se synchronise automatiquement dans Firestore
Une notification push à 19h rappelle les membres qui n'ont pas encore lu
Quand quelqu'un marque un jour comme lu → notification push aux autres membres du groupe
5. Gestion
Hôte : menu ⋮ → "Supprimer le groupe" (supprime tout de Firestore)
Membre : menu ⋮ → "Quitter le groupe" (retire son document membre)
Se déconnecter : Réglages → section COMPTE → "Se déconnecter"
Ce qui manque encore
Manquant	Impact
Deep links fonctionnels	Le lien dans le message ne rouvre pas l'app automatiquement — il faut saisir le code manuellement
Firestore Database créée	Sans ça, rien du groupe ne fonctionne (groupes non chargés, création impossible)
Cloud Functions déployées	Les notifications push ne partent pas
