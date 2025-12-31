# Structure du Projet

## Vue d'ensemble

```
rapport_comptable/
├── main.py                    # Point d'entrée principal de l'application
├── config.json                # Configuration centralisée
├── requirements.txt           # Dépendances Python
├── README.md                  # Documentation principale
├── LICENSE                    # Licence propriétaire
├── .gitignore                 # Fichiers à ignorer par Git
├── run.bat                    # Script de lancement Windows
├── run.sh                     # Script de lancement Linux/Mac
│
├── modules/                   # Modules fonctionnels
│   ├── __init__.py
│   ├── sage_parser.py         # Parsing du fichier Sage TXT
│   ├── data_processor.py      # Traitement et calculs comptables
│   ├── excel_generator.py     # Génération du fichier Excel
│   ├── ppt_generator.py       # Génération du rapport PowerPoint
│   └── ui_interface.py        # Interface graphique Tkinter
│
├── utils/                     # Utilitaires transverses
│   ├── __init__.py
│   ├── logger.py              # Configuration du logging
│   ├── exceptions.py          # Exceptions personnalisées
│   └── validators.py          # Fonctions de validation
│
├── templates/                 # Templates
│   └── (rapport_template.pptx à ajouter)
│
├── tests/                     # Tests unitaires
│   ├── __init__.py
│   ├── test_parser.py         # Tests du parser
│   ├── test_processor.py      # Tests du processeur
│   └── test_generators.py     # Tests des générateurs
│
└── docs/                      # Documentation
    └── INSTALLATION.md        # Guide d'installation
```

## Description des fichiers

### Fichiers principaux

#### main.py
Point d'entrée de l'application. Orchestre le flux complet:
1. Sélection du fichier Sage
2. Parsing et validation
3. Traitement des données
4. Génération Excel
5. Saisie des commentaires
6. Génération PowerPoint

#### config.json
Configuration centralisée avec:
- Chemins des fichiers
- Paramètres de parsing Sage
- Styles Excel
- Configuration PowerPoint
- Paramètres de logging

#### requirements.txt
Liste des dépendances Python:
- pandas (traitement de données)
- openpyxl (génération Excel)
- python-pptx (génération PowerPoint)
- Pillow (manipulation d'images)
- pytest (tests)

### Modules fonctionnels

#### modules/sage_parser.py
**Responsabilités:**
- Lecture du fichier TXT avec encodage ISO-8859-1
- Parsing des colonnes délimitées par tabulations
- Validation et nettoyage des données
- Conversion en DataFrame Pandas

**Fonctions principales:**
- `parse_sage_file()`: Parse le fichier complet
- `validate_data()`: Valide la cohérence des données
- `clean_data()`: Nettoie les données
- `filter_by_account()`: Filtre par préfixe de compte

#### modules/data_processor.py
**Responsabilités:**
- Calcul de la balance générale
- Génération du bilan (Actif/Passif)
- Génération du compte de résultat (Charges/Produits)
- Calcul des Soldes Intermédiaires de Gestion (SIG)

**Fonctions principales:**
- `calculate_balance()`: Agrège par compte
- `generate_bilan()`: Extrait Actif et Passif
- `generate_compte_resultat()`: Extrait Charges et Produits
- `calculate_sig()`: Calcule CA, EBE, Résultat

#### modules/excel_generator.py
**Responsabilités:**
- Création du classeur Excel multi-feuilles
- Insertion des données
- Application du formatage (couleurs, bordures)
- Insertion des formules Excel

**Fonctions principales:**
- `create_workbook()`: Crée le classeur complet
- `add_grand_livre_sheet()`: Ajoute la feuille Grand Livre
- `add_balance_sheet()`: Ajoute la feuille Balance
- `add_bilan_sheet()`: Ajoute la feuille Bilan
- `save_workbook()`: Sauvegarde le fichier

**Feuilles générées:**
1. GL BI SEP - Grand Livre complet
2. BG BI SEP - Balance générale
3. BILAN SYNTH - Synthèse du bilan
4. CR SYNTH - Compte de résultat
5. SIG - Soldes Intermédiaires de Gestion
6. SUIVI ACTIVITE - Suivi mensuel

#### modules/ppt_generator.py
**Responsabilités:**
- Chargement du template PowerPoint
- Mise à jour des dates
- Insertion des événements et commentaires
- Génération du rapport final

**Fonctions principales:**
- `generate_powerpoint()`: Génère le rapport complet
- `load_template()`: Charge le template
- `create_basic_presentation()`: Crée une présentation de base
- `insert_evenements()`: Insère les événements
- `insert_commentaires()`: Insère les commentaires

#### modules/ui_interface.py
**Responsabilités:**
- Interface graphique Tkinter
- Saisie des événements significatifs
- Saisie des commentaires
- Sauvegarde en JSON

**Composants:**
- Classe `CommentaireInterface`: Interface graphique
- Fonction `collect_user_input()`: Point d'entrée

### Utilitaires

#### utils/exceptions.py
Hiérarchie des exceptions personnalisées:
```
RapportException (base)
├── ParsingError
│   ├── FileFormatError
│   └── EncodingError
├── DataValidationError
│   ├── InvalidAccountError
│   └── InvalidDateError
├── GenerationError
│   ├── ExcelGenerationError
│   └── PowerPointGenerationError
└── ConfigurationError
```

#### utils/logger.py
Configuration du système de logging:
- Logs console (INFO+)
- Logs fichier complet (DEBUG+)
- Logs erreurs uniquement (ERROR+)
- Format: timestamp - module - niveau - message

#### utils/validators.py
Fonctions de validation:
- `validate_account_number()`: Valide un numéro de compte
- `validate_date()`: Valide une date
- `validate_balance_equilibrium()`: Vérifie l'équilibre
- `validate_journal_code()`: Valide un code journal
- `check_solde_coherence()`: Vérifie la cohérence des soldes

### Tests

#### tests/test_parser.py
Tests du module de parsing:
- Test de parsing avec succès
- Test fichier inexistant
- Test validation des données
- Test nettoyage des données
- Test filtrage par compte

#### tests/test_processor.py
Tests du module de traitement:
- Test calcul de la balance
- Test génération du bilan
- Test génération du compte de résultat
- Test calcul des SIG
- Test filtrage par classe

#### tests/test_generators.py
Tests des générateurs:
- Test création du classeur Excel
- Test sauvegarde Excel
- Test création de la présentation PowerPoint
- Test sauvegarde PowerPoint

## Flux de données

```
1. Fichier Sage TXT (encodage ISO-8859-1)
   ↓
2. sage_parser.py → DataFrame Grand Livre
   ↓
3. data_processor.py → Balance, Bilan, CR, SIG
   ↓
4. excel_generator.py → Fichier Excel (.xlsx)
   ↓
5. ui_interface.py → Saisie événements et commentaires
   ↓
6. ppt_generator.py → Rapport PowerPoint (.pptx)
```

## Logs et traçabilité

**Fichiers de logs:**
- `logs/rapport_YYYYMMDD_HHMMSS.log` - Logs complets
- `logs/rapport_errors.log` - Erreurs uniquement

**Fichiers temporaires:**
- `temp_commentaires.json` - Sauvegarde des commentaires

## Fichiers de sortie

**Nomenclature:**
- `SUIVI_ACTIVITE_YYYYMMDD_HHMMSS.xlsx` - Fichier Excel
- `RAPPORT_COMPTABLE_YYYYMMDD_HHMMSS.pptx` - Rapport PowerPoint

**Emplacement:**
Même dossier que le fichier Sage source

## Statut du projet

✅ Structure complète créée
✅ Tous les modules implémentés
✅ Tests unitaires écrits
✅ Documentation complète
✅ Scripts de lancement (Windows/Linux)
✅ Configuration centralisée
✅ Gestion des erreurs robuste
✅ Système de logging complet

## Prochaines étapes

1. Copier le template PowerPoint dans `templates/rapport_template.pptx`
2. Tester avec le fichier réel: `TESTE BIMMO_exportation.txt`
3. Installer les dépendances: `pip install -r requirements.txt`
4. Lancer l'application: `python main.py` ou `./run.sh`
5. Exécuter les tests: `pytest tests/`

## Notes importantes

- Tous les fichiers sont encodés en UTF-8
- Le parsing Sage utilise ISO-8859-1
- Les logs sont sauvegardés automatiquement
- Les fichiers temporaires sont dans .gitignore
- La licence est propriétaire (2BN CONSULTING)
