# Guide Utilisateur - Générateur de Rapports Comptables

## 🚀 Démarrage Rapide

### Lancement de l'Application

1. Double-cliquez sur **RapportComptable.exe**
2. L'interface de configuration s'ouvre automatiquement

### Génération d'un Rapport - Étapes Simples

#### Étape 1 : Configuration

L'interface de configuration vous demande :

1. **Fichier source Sage** : Cliquez sur "Parcourir" et sélectionnez votre fichier TXT exporté depuis Sage
2. **Dossier de sortie** : Choisissez où sauvegarder les rapports (par défaut : Documents)
3. **Options** :
   - ☑ Générer Excel (recommandé)
   - ☑ Générer PowerPoint (recommandé)
4. **Période** : Exemple : "Septembre 2025", "Q3 2025", etc.
5. **Cabinet** : Nom de votre cabinet (par défaut : 2BN CONSULTING)
6. **Client** : Nom du client (par défaut : BAMBOO IMMO)

Cliquez sur **"Générer les rapports"**

#### Étape 2 : Génération Automatique

L'application génère automatiquement :
- ✅ Fichier Excel avec tous les tableaux
- ✅ Présentation PowerPoint avec mise en page professionnelle

**Durée** : 30 secondes à 2 minutes selon la taille des données

#### Étape 3 : Enrichissement des Commentaires (Optionnel)

Après la génération, l'interface d'enrichissement s'ouvre :

1. Ajoutez vos commentaires dans les zones de texte
2. Utilisez les boutons de formatage :
   - **B** : Gras
   - **I** : Italique
   - **•** : Puces
3. Cliquez sur **"Mettre à jour PowerPoint"** pour intégrer les commentaires

#### Étape 4 : Résultats

Les fichiers sont créés dans le dossier de sortie :
- `rapport_BAMBOO_IMMO_2025-10-20.xlsx`
- `rapport_BAMBOO_IMMO_2025-10-20.pptx`

## 📋 Prérequis Système

### Configuration Minimale

- **Système d'exploitation** : Windows 10 ou supérieur (64-bit)
- **Mémoire RAM** : 4 GB minimum (8 GB recommandé)
- **Espace disque** : 500 MB libre
- **Microsoft Excel** : Installé (pour l'automatisation)

### Logiciels Requis

✅ **Inclus dans l'exécutable** :
- Python et toutes les bibliothèques
- Modules de traitement Excel
- Modules de génération PowerPoint
- Interface graphique

❌ **Requis sur votre PC** :
- Microsoft Excel (pour l'ouverture et l'automatisation)

## 📁 Format du Fichier Source Sage

### Structure Requise

Le fichier TXT exporté depuis Sage doit contenir :

```
Journal    CompteNum    CompteLib              Débit        Crédit    ...
530        101000       CAPITAL                             500000
...
```

### Comment Exporter depuis Sage

1. Ouvrez Sage Comptabilité
2. Allez dans **États → Grand Livre**
3. Sélectionnez la période
4. Exportez au format **TXT** ou **CSV**
5. Sélectionnez ce fichier dans l'application

## 🎨 Utilisation de l'Interface

### Interface de Configuration

![Configuration Interface]

**Champs** :
- **Fichier source** : Fichier TXT/CSV depuis Sage
- **Dossier sortie** : Où enregistrer les rapports
- **Période** : Libellé de la période (ex: "Septembre 2025")
- **Cabinet** : Votre cabinet comptable
- **Client** : Nom du client

### Interface d'Enrichissement des Commentaires

![Commentaire Interface]

**Sections disponibles** :
1. **Bilan** : Commentaires sur la situation financière
2. **Compte de Résultat** : Analyse de l'activité
3. **SIG** : Commentaires sur les soldes intermédiaires
4. **Synthèse Mensuelle** : Vue d'ensemble mensuelle
5. **Décisions** : Recommandations et décisions

**Formatage** :
- **Gras** : Sélectionnez le texte et cliquez sur "B"
- **Italique** : Sélectionnez le texte et cliquez sur "I"
- **Puces** : Commencez la ligne par "•" ou "-"

### Sauvegarde et Chargement des Commentaires

**Sauvegarder** :
1. Cliquez sur "Sauvegarder commentaires"
2. Choisissez un nom de fichier (format TXT)
3. Les commentaires sont sauvegardés avec le formatage

**Charger** :
1. Cliquez sur "Charger commentaires"
2. Sélectionnez un fichier TXT précédemment sauvegardé
3. Les commentaires se chargent automatiquement

## 📊 Contenu des Rapports

### Fichier Excel Généré

**Feuilles incluses** :
1. **BILAN SYNTH** : Bilan synthétique (Actif/Passif)
2. **CR SYNTH** : Compte de résultat synthétique
3. **SIG** : Soldes intermédiaires de gestion
4. **SUIVI ACTIVITE** : Détail mensuel de l'activité
5. **Annexes** : Tableaux détaillés par compte

**Formatage** :
- En-têtes en bleu
- Totaux en jaune
- Négatifs en rouge
- Lignes alternées pour la lisibilité

### Présentation PowerPoint Générée

**Slides incluses** :

1. **Page de titre** : Rapport Comptable + Client + Période
2. **Sommaire** : Table des matières
3. **Objectif** : But du rapport
4. **Événements** : Faits marquants de la période
5-6. **Bilan** : Tableau + Commentaires
7-8. **Activité** : Compte de résultat + Commentaires
9-10. **SIG** : Soldes intermédiaires + Analyse
11. **Mensuel** : Suivi mensuel de l'activité
12. **Décisions** : Recommandations et décisions
13-15. **Annexes** : Tableaux détaillés
16. **Remerciements** : Slide de fin

**Design** :
- Template professionnel avec header/footer
- Pagination automatique
- Dates dynamiques
- Tableaux formatés
- Commentaires stylisés avec icônes

## ❓ Questions Fréquentes (FAQ)

### Q : L'application ne démarre pas

**R** : Vérifiez que :
1. Vous avez les droits administrateur
2. L'antivirus ne bloque pas l'exe (ajoutez une exception)
3. Vous avez Windows 10 ou supérieur

### Q : Erreur "Fichier Sage invalide"

**R** : Assurez-vous que :
1. Le fichier TXT contient les colonnes requises
2. Le fichier est bien au format texte (TXT ou CSV)
3. Le fichier n'est pas vide

### Q : Le PowerPoint n'a pas de commentaires

**R** : C'est normal ! Les commentaires sont optionnels.
1. Lors de la première génération, le PPT contient les tableaux sans commentaires
2. Utilisez l'interface d'enrichissement pour ajouter les commentaires
3. Cliquez sur "Mettre à jour PowerPoint" pour les intégrer

### Q : Les tableaux débordent dans le PowerPoint

**R** : Les tableaux sont dimensionnés automatiquement, mais si un tableau est très grand :
1. Réduisez le nombre de lignes/colonnes dans Excel
2. Ou acceptez que certaines données soient tronquées
3. Les tableaux Excel contiennent toutes les données

### Q : Comment modifier le design du PowerPoint ?

**R** : Le design est codé dans l'application. Pour le modifier :
1. Contactez le développeur
2. Ou modifiez manuellement le PowerPoint après génération

### Q : Puis-je utiliser l'application sans Excel installé ?

**R** : Non, Microsoft Excel est requis pour :
1. L'automatisation COM (sur Windows)
2. L'ouverture des fichiers générés

## 🆘 Support et Assistance

### En Cas de Problème

1. **Vérifiez les logs** : Un dossier `logs` est créé avec les détails des erreurs
2. **Consultez la FAQ** ci-dessus
3. **Contactez le support** avec :
   - Description du problème
   - Message d'erreur exact
   - Fichier de log (`logs/rapport_YYYY-MM-DD.log`)

### Informations de Support

- **Email** : support@votrecabinet.com (à personnaliser)
- **Téléphone** : +33 X XX XX XX XX (à personnaliser)

## 📝 Notes de Version

### Version 1.0 (Date actuelle)

**Fonctionnalités** :
- ✅ Interface graphique complète
- ✅ Configuration intuitive
- ✅ Génération Excel automatique
- ✅ Génération PowerPoint avec design professionnel
- ✅ Enrichissement des commentaires avec formatage
- ✅ Sauvegarde/Chargement des commentaires en TXT
- ✅ Dates et noms dynamiques
- ✅ Logs détaillés pour débogage

**Limitations connues** :
- Fonctionne uniquement sur Windows
- Nécessite Microsoft Excel installé
- Tableaux très larges peuvent déborder (rare)

## 📄 Licence et Copyright

**© 2025 Votre Cabinet Comptable** (à personnaliser)

Ce logiciel est fourni "en l'état" sans garantie. L'utilisation est soumise aux termes de la licence fournie.

---

**Bon rapport comptable ! 📊✨**
