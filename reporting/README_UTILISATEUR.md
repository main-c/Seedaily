# Guide Utilisateur - Générateur de Rapports Comptables

## Installation

### Prérequis
- Python 3.8 ou supérieur installé sur votre ordinateur
- Les bibliothèques Python nécessaires (voir `requirements.txt`)

### Installation des dépendances
```bash
pip install -r requirements.txt
```

## Utilisation Simple (Recommandée)

### Sur Linux/Mac
Double-cliquez sur le fichier `lancer_rapport.sh` ou exécutez dans un terminal:
```bash
./lancer_rapport.sh
```

### Sur Windows
Double-cliquez sur le fichier `lancer_rapport.bat`

### Manuellement
```bash
python3 rapport_comptable/main.py
```

## Guide pas à pas

### 1. Lancement de l'application
Une fois lancée, une fenêtre graphique s'ouvre avec plusieurs onglets.

### 2. Onglet "⚙️ Configuration" (À faire en premier)

**Fichier source Sage:**
- Cliquez sur le bouton "📁 Parcourir..."
- Sélectionnez le fichier TXT exporté depuis votre logiciel Sage
- Le chemin du fichier s'affiche dans la zone de texte

**Dossier de sauvegarde:**
- Cliquez sur "📁 Choisir dossier..."
- Sélectionnez le dossier où vous souhaitez sauvegarder les rapports
- Par défaut: votre dossier Documents

**Options de génération:**
- ☑️ Générer le rapport Excel (.xlsx) - Cochez si vous voulez le fichier Excel
- ☑️ Générer la présentation PowerPoint (.pptx) - Cochez si vous voulez la présentation

### 3. Onglet "Informations Générales"

Remplissez les informations de base:
- **Période:** Par exemple "Septembre 2025"
- **Cabinet:** Nom de votre cabinet (pré-rempli avec "2BN CONSULTING")
- **Client:** Nom du client (pré-rempli avec "BAMBOO IMMO")

### 4. Onglets de commentaires

Pour chaque section (Bilan, Compte de Résultat, SIG, Suivi d'Activité, Synthèse):

**Saisie de texte:**
- Cliquez dans la zone de texte
- L'exemple en gris disparaît automatiquement
- Tapez vos commentaires

**Formatage du texte:**
- **Gras:** Sélectionnez le texte et cliquez sur "Gras (Ctrl+B)" ou pressez Ctrl+B
- **Italique:** Sélectionnez le texte et cliquez sur "Italique (Ctrl+I)" ou pressez Ctrl+I
- **Puces:** Cliquez sur "• Liste à puces" pour ajouter une puce au début de la ligne

**Exemple d'utilisation du formatage:**
```
Sélectionnez "Points importants" → Cliquez sur Gras
Tapez une nouvelle ligne → Cliquez sur "• Liste à puces"
Tapez votre point → Entrée pour la ligne suivante
```

### 5. Sauvegarde des commentaires (Optionnel mais recommandé)

Pour sauvegarder vos commentaires et les réutiliser plus tard:
- Cliquez sur "💾 Sauvegarder commentaires"
- Choisissez un nom de fichier (extension .txt recommandée)
- Le fichier est sauvegardé en format texte lisible

**Pourquoi sauvegarder?**
- Vous pouvez éditer le fichier avec n'importe quel éditeur de texte
- Vous pouvez réutiliser les commentaires pour le mois suivant
- Facile à partager avec des collègues

### 6. Chargement de commentaires existants

Si vous avez déjà un fichier de commentaires:
- Cliquez sur "📂 Charger commentaires"
- Sélectionnez votre fichier .txt (ou .json pour les anciens formats)
- Les commentaires sont chargés dans tous les onglets

### 7. Génération des rapports

Une fois tout configuré:
1. Cliquez sur "✅ Générer les rapports"
2. Une fenêtre de confirmation s'affiche avec le résumé:
   - Fichier source
   - Dossier de sortie
   - Options choisies (Excel et/ou PowerPoint)
3. Cliquez sur "Oui" pour lancer la génération
4. Patientez pendant le traitement (quelques secondes à quelques minutes)
5. Les fichiers sont créés dans le dossier choisi

## Raccourcis clavier

- **Ctrl+B** - Mettre en gras le texte sélectionné
- **Ctrl+I** - Mettre en italique le texte sélectionné

## Format des fichiers de commentaires

Les fichiers de commentaires sont sauvegardés en format texte simple:

```
PÉRIODE: Septembre 2025
CABINET: 2BN CONSULTING
CLIENT: BAMBOO IMMO

=== BILAN ===
Vos commentaires sur le bilan...

=== COMPTE DE RÉSULTAT ===
Vos commentaires sur le compte de résultat...
```

Ce format est:
- ✅ Lisible par tout le monde
- ✅ Éditable avec Notepad, Word, etc.
- ✅ Facile à envoyer par email
- ✅ Pas besoin de connaissances techniques

## Boutons de l'interface

| Bouton | Description |
|--------|-------------|
| 📝 **Nouveau document** | Efface tous les champs pour recommencer |
| 📂 **Charger commentaires** | Ouvre un fichier de commentaires existant |
| 💾 **Sauvegarder commentaires** | Sauvegarde vos commentaires en fichier .txt |
| ✅ **Générer les rapports** | Lance la génération des rapports Excel/PowerPoint |

## Fichiers générés

Les fichiers sont sauvegardés avec un horodatage automatique:
- `RAPPORT_[nom_fichier]_[date]_[heure].xlsx` - Fichier Excel
- `RAPPORT_[nom_fichier]_[date]_[heure].pptx` - Présentation PowerPoint

**Exemple:**
- `RAPPORT_sage_export_20251020_143052.xlsx`
- `RAPPORT_sage_export_20251020_143052.pptx`

## Résolution des problèmes

### L'application ne se lance pas
- Vérifiez que Python est installé: `python3 --version`
- Vérifiez que les dépendances sont installées: `pip install -r requirements.txt`

### Erreur "Fichier source introuvable"
- Vérifiez que vous avez bien sélectionné un fichier dans l'onglet Configuration
- Vérifiez que le fichier existe toujours à l'emplacement indiqué

### Les boutons de formatage ne fonctionnent pas
- Vous devez d'abord **sélectionner du texte** avant de cliquer sur Gras ou Italique
- Pour les puces, placez simplement le curseur au début de la ligne

### Le fichier Excel ou PowerPoint n'est pas généré
- Vérifiez que l'option correspondante est cochée dans Configuration
- Vérifiez que vous avez les droits d'écriture dans le dossier de sortie
- Consultez les logs dans le dossier `logs/`

## Support et Logs

En cas de problème, consultez les fichiers de log dans le dossier `logs/`:
- Chaque exécution crée un nouveau fichier log avec horodatage
- Les logs contiennent des informations détaillées sur le traitement
- Partagez le fichier log avec le support technique en cas de problème

## Astuces

1. **Sauvegardez régulièrement** vos commentaires pour ne pas perdre votre travail
2. **Réutilisez les commentaires** des mois précédents comme point de départ
3. **Utilisez le formatage** (gras, puces) pour rendre vos rapports plus lisibles
4. **Vérifiez l'onglet Configuration** avant de générer pour être sûr des options
5. **Créez un dossier dédié** pour chaque période (ex: "Rapports_Septembre_2025")

## Contact

Pour toute question ou problème, contactez le support technique.
