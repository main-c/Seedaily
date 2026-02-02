# 📋 Fiche de Brief Design - Seedaily

## 🎯 Présentation du Projet

**Seedaily** est une application mobile de plans de lecture biblique qui permet aux utilisateurs de suivre leur progression quotidienne dans la lecture de la Bible.

**Plateforme cible** : Mobile (iOS & Android) via Flutter
**Public cible** : Chrétiens francophones souhaitant lire la Bible de manière structurée

---

## 🎨 Identité Visuelle Actuelle

### Palette de Couleurs
| Couleur | Hex | Usage |
|---------|-----|-------|
| Seed Gold | `#EF9D10` | Couleur principale, accents, progression |
| Deep Navy | `#3B4D61` | Texte principal, headers |
| Surface | `#FFFFFF` | Fond des cartes |
| Background Light | `#F7F8FA` | Fond général |
| Text Muted | `#7A8699` | Texte secondaire |
| Border Subtle | `#E8EAED` | Bordures légères |

### Typographie
- Police système (San Francisco / Roboto)
- Hiérarchie : Headlines, Titles, Body, Labels

---

## 📱 Écrans à Designer

### 1. ÉCRAN D'ACCUEIL (Home)

#### Fonctionnalités requises :
- [ ] Afficher la liste des plans de lecture de l'utilisateur
- [ ] Filtrer par : Tous / En cours / Terminés
- [ ] Accès rapide au plan du jour (lecture à faire aujourd'hui)
- [ ] Statistiques globales (nombre de plans, streak global)
- [ ] Bouton d'action pour créer un nouveau plan

#### Informations à afficher par plan :
- Titre du plan
- Image/illustration du plan
- Progression (barre + pourcentage)
- Streak actuel (jours consécutifs)
- Jour actuel / Total jours
- Date de fin estimée

#### Interactions souhaitées :
- Tap sur un plan → Ouvrir le détail
- Swipe gauche → Options (supprimer, archiver)
- Pull to refresh → Actualiser les données

#### Inspiration :
- YouVersion Bible App (onglet Plans)
- Notion (liste de projets)

---

### 2. ÉCRAN DÉCOUVERTE DES PLANS (Browse Plans)

#### Fonctionnalités requises :
- [ ] Catalogue de tous les plans disponibles
- [ ] Organisation par catégories/sections
- [ ] Recherche par nom ou mot-clé
- [ ] Filtres (durée, type, testament)

#### Catégories de plans :
1. **Bible intégrale** - Plans pour lire toute la Bible
   - Plan canonique (Genèse → Apocalypse)
   - Plan chronologique
   - Plan M'Cheyne (4 passages/jour)
   - Plan Horner (10 chapitres/jour)

2. **Par livres** - Plans ciblés
   - Nouveau Testament
   - Ancien Testament
   - Évangiles
   - Psaumes
   - Proverbes

3. **Plans thématiques** (futur)
   - Sur la prière
   - Sur la foi
   - etc.

#### Informations par template :
- Image de couverture
- Titre
- Description courte
- Durée estimée
- Difficulté/intensité (léger, modéré, intense)
- Nombre d'utilisateurs (social proof)

#### Interactions :
- Tap sur un template → Détail du template ou directement personnalisation
- Bouton favori/bookmark pour sauvegarder

---

### 3. ÉCRAN DE PERSONNALISATION DU PLAN (Customize Plan)

#### Fonctionnalités requises :
- [ ] Prévisualisation en temps réel du plan
- [ ] Options de personnalisation selon le type de plan

#### Options de personnalisation :

**Calendrier & Planning**
- Date de début (calendrier picker)
- Jours de lecture (sélection multiple : Lun-Dim)
- Durée cible (en jours/semaines/mois)

**Contenu** (pour plans personnalisables)
- Sélection des livres bibliques à inclure
- Ordre de lecture (canonique, chronologique, inversé)
- Inclusion Psaumes quotidien (oui/non)
- Inclusion Proverbe quotidien (oui/non)

**Format d'affichage**
- 📅 Calendrier mensuel
- 📋 Liste journalière
- 📆 Vue par semaine
- 📖 Vue par livre

**Options d'affichage**
- Cases à cocher (oui/non)
- Afficher les statistiques (oui/non)

#### Prévisualisation :
- Aperçu interactif du plan selon le format choisi
- Statistiques estimées (jours, chapitres, chapitres/jour)
- Navigation dans l'aperçu

#### Actions :
- Bouton "Créer le plan" → Génère et sauvegarde
- Bouton "Réinitialiser" → Valeurs par défaut

---

### 4. ÉCRAN DÉTAIL D'UN PLAN (Plan Detail)

C'est l'écran **le plus important** - l'utilisateur y passera le plus de temps.

#### Fonctionnalités requises :
- [ ] Header avec statistiques de progression
- [ ] Affichage des lectures selon le format choisi
- [ ] Marquer une lecture comme terminée
- [ ] Navigation entre les jours/semaines/mois
- [ ] Accès rapide au jour actuel

#### Header - Statistiques à afficher :
- Progression globale (barre + pourcentage)
- Jours complétés / Total
- Streak actuel (🔥)
- Chapitres lus / Total chapitres

#### 4 Formats d'affichage à designer :

##### A) Vue Calendrier Mensuel
- Grille mensuelle classique (7 colonnes)
- Navigation mois précédent/suivant
- États des jours :
  - Jour actuel (highlight fort)
  - Jours complétés (✓ ou couleur)
  - Jours passés non complétés (warning)
  - Jours futurs (neutre)
- Tap sur un jour → Affiche les passages à lire
- Références bibliques visibles dans chaque cellule

##### B) Vue Liste Journalière
- Liste verticale scrollable
- Chaque jour = une carte
- Structure d'une carte jour :
  ```
  ┌─────────────────────────────────────┐
  │ [Header] Lundi 6 janvier            │
  │─────────────────────────────────────│
  │ ☐ Gen 1-3          ☐ Ps 1          │
  │   (chips cliquables)                │
  └─────────────────────────────────────┘
  ```
- Checkbox pour marquer le jour complet
- Ou checkboxes individuelles par passage
- Badge "Aujourd'hui" sur le jour actuel

##### C) Vue par Semaine
Cf. capture de référence fournie (style YouVersion)
- Navigation semaine par semaine (< date >)
- Titre : "Week of [date]"
- Sections par jour de la semaine (Sunday, Monday...)
- Passages en chips horizontales
- Checkbox par ligne de passages
- États : complété (barré + checkbox bleue) / à faire

##### D) Vue par Livre
- Regroupement par livre biblique
- Header par livre avec :
  - Nom du livre
  - Badge AT/NT
  - Nombre de chapitres
  - Nombre de jours concernés
- Liste des jours sous chaque livre
- Progression par livre (optionnel)

#### Interactions globales :
- Tap checkbox → Marquer comme lu (avec animation satisfaisante)
- Tap passage → Ouvrir dans app Bible externe (futur)
- Bouton flottant "Aujourd'hui" → Scroll au jour actuel
- Export PDF / Partage

---

### 5. ÉCRAN PARAMÈTRES (Settings)

#### Options à inclure :
- [ ] Thème (clair/sombre/système)
- [ ] Notifications de rappel
- [ ] Heure de rappel quotidien
- [ ] Version de la Bible par défaut
- [ ] Langue de l'interface
- [ ] À propos / Crédits
- [ ] Exporter/Importer données

---

### 6. ÉTATS VIDES & FEEDBACK

#### Empty States à designer :
- Aucun plan créé (Home vide)
- Aucun résultat de recherche
- Catégorie vide

#### Feedback utilisateur :
- Toast/Snackbar de confirmation
- Animation de complétion (confetti? checkmark animé?)
- Loader pendant génération du plan
- Erreur de connexion

---

## 🔄 Flux Utilisateur Principal

```
┌─────────────┐     ┌──────────────┐     ┌─────────────────┐     ┌──────────────┐
│   Home      │ ──► │  Découvrir   │ ──► │ Personnaliser   │ ──► │  Détail      │
│  (Mes plans)│     │  (Templates) │     │   le plan       │     │  du plan     │
└─────────────┘     └──────────────┘     └─────────────────┘     └──────────────┘
                                                                        │
                                                                        ▼
                                                                 ┌──────────────┐
                                                                 │  Lecture     │
                                                                 │  quotidienne │
                                                                 └──────────────┘
```

**Parcours type** :
1. L'utilisateur ouvre l'app → Home avec ses plans
2. Il clique sur "Créer un plan" → Catalogue des templates
3. Il choisit un template → Écran de personnalisation
4. Il configure et valide → Plan créé, retour Home
5. Chaque jour, il ouvre son plan → Marque ses lectures

---

## ✨ Fonctionnalités Clés à Mettre en Valeur

### 1. Progression & Gamification
- Streak (série de jours consécutifs) avec icône 🔥
- Pourcentage de progression visible
- Célébration à la complétion (100%)
- Badges/achievements (futur)

### 2. Flexibilité
- 4 formats d'affichage différents
- Personnalisation complète des plans
- Choix des jours de lecture

### 3. Simplicité
- Un tap pour marquer comme lu
- Navigation intuitive
- Pas de surcharge d'informations

---

## 📐 Contraintes Techniques

- **Responsive** : Adapter aux différentes tailles d'écran mobile
- **Accessibilité** : Contrastes suffisants, tailles de police lisibles
- **Performance** : Plans pouvant contenir 365+ jours
- **Offline** : L'app doit fonctionner sans connexion
- **Dark Mode** : Prévoir une variante sombre

---

## 🎯 Objectifs UX

1. **Simplicité** - L'utilisateur doit comprendre l'app en 30 secondes
2. **Motivation** - Encourager la lecture quotidienne (streak, progression)
3. **Clarté** - Savoir immédiatement ce qu'il faut lire aujourd'hui
4. **Satisfaction** - Feedback gratifiant lors du marquage des lectures

---

## 📎 Références & Inspirations

### Apps similaires :
- **YouVersion Bible** - Plans de lecture, UI épurée
- **Dwell** - Design premium, audio Bible
- **Lectio 365** - Méditation guidée quotidienne
- **Glorify** - Design moderne, gamification

### Inspirations UI générales :
- Notion (organisation, listes)
- Todoist (gestion de tâches, progression)
- Duolingo (gamification, streaks)
- Headspace (calme, spiritualité)

---

## 📦 Livrables Attendus

1. **Maquettes haute-fidélité** pour les 5 écrans principaux
2. **Composants UI** réutilisables (cartes, boutons, chips, etc.)
3. **4 variantes** de l'écran Détail du Plan (un par format)
4. **États** : vide, chargement, erreur, succès
5. **Mode sombre** (optionnel mais apprécié)
6. **Spécifications** : espacements, tailles, couleurs exactes

---

## 📞 Contact & Questions

Pour toute question sur les fonctionnalités ou le comportement attendu, n'hésitez pas à demander des clarifications avant de commencer.

**Priorité des écrans** :
1. 🔴 Plan Detail (4 formats) - Le plus critique
2. 🟠 Home - Premier écran vu
3. 🟡 Découvrir les plans - Catalogue
4. 🟢 Personnalisation - Création de plan
5. 🔵 Settings - Moins prioritaire

---

*Document préparé le 15 janvier 2026*
*Version 1.0*
