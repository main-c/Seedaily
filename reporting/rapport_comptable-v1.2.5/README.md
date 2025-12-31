# Système d'Automatisation de Rapports Comptables

## 📋 Description

Système automatisé de génération de rapports comptables mensuels pour le cabinet **2BN CONSULTING**. Cette solution permet de réduire le temps de production d'un rapport de **1-2 jours à environ 1 heure**.

## 🎯 Fonctionnalités principales

- ✅ **Parsing automatique** du fichier Grand Livre exporté depuis Sage (format TXT)
- ✅ **Génération Excel** avec calculs automatiques (Balance, Bilan, Compte de Résultat, SIG)
- ✅ **Interface graphique** pour saisir les événements significatifs et commentaires
- ✅ **Génération PowerPoint** automatique du rapport final
- ✅ **Support de gros volumes** (de 100 à 20 000 lignes)
- ✅ **Traçabilité complète** via système de logging

## 🚀 Installation

### Prérequis

- Python 3.8 ou supérieur
- Windows (recommandé) ou Linux/macOS

### Installation des dépendances

```bash
cd rapport_comptable
pip install -r requirements.txt
```

## 📖 Utilisation

### Étape 1: Export depuis Sage

1. Ouvrir Sage et accéder au Grand Livre
2. Exporter au format **TXT délimité par tabulations**
3. S'assurer de l'encodage **ISO-8859-1**
4. Sauvegarder le fichier

### Étape 2: Lancer le programme

```bash
python main.py
```

### Étape 3: Suivre le processus

1. **Sélectionner le fichier TXT** exporté depuis Sage
2. Le système traite les données (2-5 minutes selon le volume)
3. **Saisir les événements significatifs** et commentaires dans l'interface
4. Valider pour générer le rapport PowerPoint final

### Étape 4: Récupérer les fichiers

Les fichiers générés se trouvent dans le même répertoire que le fichier source:
- `SUIVI_ACTIVITE_YYYYMMDD_HHMMSS.xlsx` - Fichier Excel
- `RAPPORT_COMPTABLE_YYYYMMDD_HHMMSS.pptx` - Rapport PowerPoint final

## 📁 Structure du projet

```
rapport_comptable/
├── main.py                    # Point d'entrée principal
├── config.json               # Configuration
├── requirements.txt          # Dépendances Python
├── README.md                 # Ce fichier
│
├── modules/                  # Modules fonctionnels
│   ├── sage_parser.py        # Parsing fichier Sage
│   ├── data_processor.py     # Traitement données
│   ├── excel_generator.py    # Génération Excel
│   ├── ppt_generator.py      # Génération PowerPoint
│   └── ui_interface.py       # Interface utilisateur
│
├── utils/                    # Utilitaires
│   ├── logger.py             # Configuration logging
│   ├── validators.py         # Validations
│   └── exceptions.py         # Exceptions personnalisées
│
├── templates/                # Templates
│   └── rapport_template.pptx # Template PowerPoint
│
├── tests/                    # Tests unitaires
│   ├── test_parser.py
│   ├── test_processor.py
│   └── test_generators.py
│
└── docs/                     # Documentation
    ├── guide_utilisateur.pdf
    └── documentation_technique.pdf
```

## ⚙️ Configuration

La configuration se trouve dans `config.json`. Vous pouvez modifier:

- Chemins des templates
- Styles Excel
- Noms des feuilles
- Paramètres de logging
- Limites de performance

## 🧪 Tests

Pour exécuter les tests:

```bash
pytest tests/
```

Pour exécuter les tests avec couverture:

```bash
pytest --cov=modules tests/
```

## 📊 Performance

| Volume de données | Temps de traitement |
|-------------------|---------------------|
| 100 lignes        | < 1 minute          |
| 1 000 lignes      | < 3 minutes         |
| 20 000 lignes     | < 20 minutes        |

## 🐛 Résolution de problèmes

### Erreur d'encodage
- Vérifier que le fichier Sage est bien encodé en **ISO-8859-1**

### Fichier Excel ne s'ouvre pas
- Vérifier que Microsoft Excel ou LibreOffice est installé
- Vérifier les permissions en écriture

### Interface graphique ne s'affiche pas
- Vérifier que tkinter est installé (inclus par défaut avec Python)

## 📝 Logs

Les logs sont enregistrés dans:
- `logs/rapport_YYYYMMDD.log` - Logs complets
- `logs/rapport_errors.log` - Erreurs uniquement

## 🔒 Sécurité et confidentialité

- ✅ Tous les fichiers sont traités **localement**
- ✅ Aucune transmission vers le cloud
- ✅ Données confidentielles protégées
- ✅ Logs accessibles uniquement au chef hiérarchique

## 👨‍💻 Développeur

**Yannik KADJIE** - Développeur Logiciel

## 📄 Licence

Propriété du cabinet **2BN CONSULTING**
Tous droits réservés © 2025

## 📞 Support

Pour toute question ou problème, consulter:
- `docs/guide_utilisateur.pdf`
- `docs/documentation_technique.pdf`

---

**Version:** 1.0
**Date:** Octobre 2025
