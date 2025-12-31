#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de test pour le Module 3 - Génération Excel
"""

import sys
from pathlib import Path
from datetime import datetime

# Ajouter le répertoire parent au path
sys.path.insert(0, str(Path(__file__).parent))

from modules.sage_parser import parse_sage_file, validate_data, clean_data
from modules.data_processor import (
    calculate_balance,
    generate_bilan,
    generate_compte_resultat,
    calculate_sig
)
from modules.excel_generator import create_workbook, save_workbook
from utils.logger import setup_logger

def main():
    """Test du Module 3 - Génération Excel"""

    # Configuration du logger
    logger = setup_logger()

    print("=" * 80)
    print("TEST MODULE 3 - GÉNÉRATION EXCEL")
    print("=" * 80)
    print()

    # Charger les données avec Modules 1 et 2
    test_file = Path(__file__).parent.parent / "TESTE BIMMO_exportation.txt"

    if not test_file.exists():
        print(f"❌ ERREUR: Fichier de test introuvable: {test_file}")
        return

    print(f"📁 Fichier source: {test_file.name}")
    print()

    # Étape 1: Parser et nettoyer (Module 1)
    print("🔄 Étape 1: Parsing du fichier...")
    df = parse_sage_file(str(test_file))
    validate_data(df)
    df_clean = clean_data(df)
    print(f"✅ {len(df_clean)} écritures chargées")
    print()

    # Étape 2: Traitement des données (Module 2)
    print("🔄 Étape 2: Traitement des données comptables...")
    balance = calculate_balance(df_clean)
    print(f"✅ Balance calculée: {len(balance)} comptes")

    # D'abord calculer le CR pour obtenir le résultat net
    cr = generate_compte_resultat(balance)
    print(f"✅ Compte de résultat: Charges={cr['total_charges']:,.2f}, Produits={cr['total_produits']:,.2f}")

    # Puis générer le bilan avec le résultat net du CR
    bilan = generate_bilan(balance, resultat_net=cr['resultat'])
    print(f"✅ Bilan généré: Actif={bilan['total_actif']:,.2f}, Passif={bilan['total_passif']:,.2f}")

    sig = calculate_sig(cr)
    print(f"✅ SIG calculés: CA={sig['chiffre_affaires']:,.2f}, Résultat={sig['resultat_net']:,.2f}")
    print()

    # Étape 3: Génération du fichier Excel (Module 3)
    print("🔄 Étape 3: Génération du fichier Excel...")
    print()

    try:
        # Créer le classeur avec toutes les feuilles
        print("   → Création du classeur Excel...")
        workbook = create_workbook(df_clean, balance, bilan, cr, sig)
        print(f"   ✅ Classeur créé avec {len(workbook.sheetnames)} feuilles")
        print()

        # Afficher les feuilles créées
        print("   📋 Feuilles générées:")
        for i, sheet_name in enumerate(workbook.sheetnames, 1):
            sheet = workbook[sheet_name]
            nb_rows = sheet.max_row
            nb_cols = sheet.max_column
            print(f"      {i}. {sheet_name:20s} - {nb_rows:4d} lignes × {nb_cols:2d} colonnes")
        print()

        # Définir le chemin de sortie
        output_dir = Path(__file__).parent.parent
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        output_file = output_dir / f"TEST_SUIVI_ACTIVITE_{timestamp}.xlsx"

        # Sauvegarder le fichier
        print(f"   → Sauvegarde du fichier...")
        save_workbook(workbook, str(output_file))
        print(f"   ✅ Fichier sauvegardé: {output_file.name}")
        print()

        # Vérifier le fichier
        if output_file.exists():
            file_size = output_file.stat().st_size
            print(f"   📊 Informations du fichier:")
            print(f"      → Nom: {output_file.name}")
            print(f"      → Taille: {file_size:,} octets ({file_size/1024:.2f} Ko)")
            print(f"      → Emplacement: {output_file.parent}")
            print()

            print("   ✅ Fichier Excel généré avec succès!")
            print()

            # Instructions pour ouvrir
            print("   📖 Pour ouvrir le fichier:")
            print(f"      → Emplacement: {output_file}")
            print(f"      → Commande: libreoffice \"{output_file}\"")
            print()

        else:
            print("   ❌ ERREUR: Le fichier n'a pas été créé")
            return

    except Exception as e:
        print(f"   ❌ ERREUR lors de la génération Excel: {e}")
        import traceback
        traceback.print_exc()
        return

    # Conclusion
    print("=" * 80)
    print("✅ TEST MODULE 3 TERMINÉ AVEC SUCCÈS!")
    print("=" * 80)
    print()
    print(f"📊 Résumé:")
    print(f"   ✓ Fichier source parsé: {test_file.name}")
    print(f"   ✓ Écritures traitées: {len(df_clean)}")
    print(f"   ✓ Comptes dans la balance: {len(balance)}")
    print(f"   ✓ Feuilles Excel créées: {len(workbook.sheetnames)}")
    print(f"   ✓ Fichier Excel généré: {output_file.name}")
    print(f"   ✓ Taille du fichier: {file_size/1024:.2f} Ko")
    print()
    print("🎯 Le Module 3 (Génération Excel) fonctionne correctement!")
    print()
    print(f"💡 Ouvrez le fichier pour vérifier le contenu:")
    print(f"   libreoffice \"{output_file}\"")
    print()

if __name__ == "__main__":
    main()
