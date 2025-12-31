# Instructions de Build - Générateur de Rapports Comptables

Ce document explique comment créer un exécutable Windows standalone (`.exe`) sans le code source.

## Prérequis

### Sur Windows (machine de build)

1. **Python 3.8 ou supérieur** installé
2. **Toutes les dépendances** installées :
   
   ```bash
   pip install -r requirements.txt
   ```
   
3. **PyInstaller** installé :
   ```bash
   pip install pyinstaller
   ```

4. **Pywin32** (pour l'automatisation Excel sur Windows) :
   
   ```bash
   pip install pywin32
   ```

### Étape 1 : Préparer l'environnement

Ouvrez PowerShell ou CMD dans le dossier `rapport_comptable` :

```bash
cd C:\chemin\vers\rapport_comptable
```

### Étape 2 : Installer PyInstaller

```bash
pip install pyinstaller
```

### Étape 3 : Créer l'exécutable

```bash
pyinstaller build_windows.spec
```

### Étape 4 : Récupérer l'exécutable

L'exécutable sera créé dans : `dist\RapportComptable.exe`

Taille approximative : 50-150 MB (dépend des dépendances)

## Livraison au Client

### Structure du Package Final

Créez un dossier avec :

```
RapportComptable_v1.0/
├── RapportComptable.exe          # Exécutable principal
├── README.md                      # Documentation utilisateur
├── GUIDE_UTILISATEUR.md          # Guide d'utilisation détaillé
├── exemple_commentaires.txt       # Exemple de fichier commentaires
└── config.json                    # (Optionnel) Configuration par défaut
```

### Fichiers à Livrer

#### 1. L'exécutable
- `RapportComptable.exe` 

#### 2. Documentation
- Guide utilisateur en français
- Exemples de fichiers

#### 3. Prérequis Système (à indiquer au client)

**Sur le PC client Windows :**

✅ **Obligatoire :**
- Windows 10 ou supérieur
- Microsoft Excel installé (pour l'automatisation COM)
- 200 MB d'espace disque libre

✅ **Optionnel (pour meilleures performances) :**
- Aucun - tout est inclus dans l'exe !

## Test de l'Exécutable

Avant de livrer, testez sur une machine propre (sans Python) :

1. Copiez `RapportComptable.exe` sur la machine de test
2. Double-cliquez sur l'exe
3. Vérifiez que l'interface graphique s'ouvre
4. Testez une génération complète de rapport
5. Vérifiez les fichiers Excel et PowerPoint générés

## Résolution de Problèmes

### Erreur : "Failed to execute script"

**Cause** : Dépendance manquante

**Solution** : Ajoutez la dépendance dans `hiddenimports` du fichier `.spec`

### Erreur : "VCRUNTIME140.dll not found"

**Cause** : Microsoft Visual C++ Redistributable manquant

**Solution** : Le client doit installer :
- [Visual C++ Redistributable](https://aka.ms/vs/17/release/vc_redist.x64.exe)

### L'exe est trop gros (>200 MB)

**Solutions** :
1. Utilisez UPX pour compresser
2. Excluez les modules inutiles dans le `.spec`
3. Utilisez `--onedir` au lieu de `--onefile` (crée un dossier au lieu d'un seul fichier)

### L'interface graphique ne s'affiche pas

**Cause** : `console=False` mais erreur au démarrage

**Solution temporaire** : Changez `console=False` à `console=True` dans le `.spec` pour voir les erreurs

## Notes Importantes

### ⚠️ Antivirus

Les exécutables PyInstaller peuvent être détectés comme suspects par certains antivirus (faux positifs).

**Solutions** :
1. Signez l'exécutable avec un certificat de signature de code
2. Soumettez l'exe à Microsoft Defender pour analyse
3. Informez le client que c'est un faux positif

### 🔒 Licence et Distribution

Assurez-vous que :
- Toutes les bibliothèques utilisées autorisent la redistribution
- Le fichier LICENSE est inclus
- Les conditions de licence sont respectées (openpyxl, python-pptx, etc.)

## Support

Pour toute question sur le build :
1. Vérifiez les logs PyInstaller : `build/RapportComptable/warn-RapportComptable.txt`
2. Testez en mode debug : `console=True` dans le `.spec`
3. Vérifiez que toutes les dépendances sont installées

## Changelog

- **v1.0** : Build initial avec PyInstaller
- Interface graphique complète
- Support Windows uniquement
- Taille ~100 MB
