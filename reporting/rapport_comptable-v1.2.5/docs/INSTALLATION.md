# Guide d'Installation

## Prérequis système

### Logiciels requis
- **Python 3.8 ou supérieur** - [Télécharger Python](https://www.python.org/downloads/)
- **pip** (gestionnaire de paquets Python, inclus avec Python)
- **Microsoft Excel** ou **LibreOffice Calc** (pour visualiser les fichiers Excel générés)

### Système d'exploitation
- Windows 10/11 (recommandé)
- Linux (Ubuntu 20.04+, Debian 11+)
- macOS 10.15+

## Installation étape par étape

### 1. Vérifier Python

Ouvrir un terminal (ou invite de commandes) et exécuter:

```bash
python --version
```

ou

```bash
python3 --version
```

Vous devez voir une version >= 3.8 (ex: `Python 3.10.5`)

### 2. Télécharger le projet

Copier le dossier `rapport_comptable` sur votre machine.

### 3. Installer les dépendances

Naviguer dans le dossier du projet:

```bash
cd rapport_comptable
```

Installer les bibliothèques requises:

```bash
pip install -r requirements.txt
```

ou

```bash
pip3 install -r requirements.txt
```

### 4. Vérifier l'installation

Exécuter:

```bash
python -c "import pandas; import openpyxl; import pptx; print('Installation réussie!')"
```

Si vous voyez "Installation réussie!", l'installation est complète.

## Configuration

### Fichier config.json

Le fichier `config.json` contient les paramètres de configuration. Vous pouvez le modifier selon vos besoins:

- `paths.template_ppt`: Chemin vers le template PowerPoint
- `sage_parser.encoding`: Encodage du fichier Sage (par défaut: ISO-8859-1)
- `logging.level`: Niveau de logging (DEBUG, INFO, WARNING, ERROR)

### Template PowerPoint

1. Copier votre template PowerPoint dans le dossier `templates/`
2. Renommer le fichier en `rapport_template.pptx`
3. Ou modifier le chemin dans `config.json`

## Premier lancement

### Test rapide

Exécuter:

```bash
python main.py
```

L'interface graphique devrait s'ouvrir pour sélectionner un fichier Sage.

## Résolution de problèmes

### Erreur: "No module named 'pandas'"

```bash
pip install pandas
```

### Erreur: "No module named 'tkinter'"

**Sur Linux:**
```bash
sudo apt-get install python3-tk
```

**Sur macOS:**
```bash
brew install python-tk
```

### Erreur d'encodage lors du parsing

Vérifier que le fichier Sage est bien encodé en ISO-8859-1. Vous pouvez le vérifier avec:

```bash
file -i votre_fichier.txt
```

### Erreur de permission lors de la sauvegarde

Vérifier que vous avez les droits en écriture dans le dossier de sortie.

## Mise à jour

Pour mettre à jour les dépendances:

```bash
pip install --upgrade -r requirements.txt
```

## Désinstallation

Pour supprimer les dépendances:

```bash
pip uninstall -r requirements.txt -y
```

Puis supprimer le dossier `rapport_comptable`.

## Support

Pour toute question, consulter:
- README.md
- Documentation technique
- Logs dans le dossier `logs/`
