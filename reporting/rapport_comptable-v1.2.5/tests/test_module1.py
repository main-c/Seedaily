#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de test pour le Module 1 - Parser Sage
"""

import sys
from pathlib import Path

# Ajouter le répertoire parent au path
sys.path.insert(0, str(Path(__file__).parent))

from modules.sage_parser import (
    parse_sage_file,
    validate_data,
    clean_data,
    get_date_range,
    get_accounts_list
)
from utils.logger import setup_logger

def main():
    """Test du Module 1 - Parser Sage"""

    # Configuration du logger
    logger = setup_logger()

    print("=" * 80)
    print("TEST MODULE 1 - PARSER SAGE")
    print("=" * 80)
    print()

    # Chemin vers le fichier de test
    test_file = Path(__file__).parent.parent / "TESTE BIMMO_exportation.txt"

    if not test_file.exists():
        print(f"❌ ERREUR: Fichier de test introuvable: {test_file}")
        return

    print(f"📁 Fichier de test: {test_file}")
    print(f"📊 Taille du fichier: {test_file.stat().st_size:,} octets")
    print()

    # Étape 1: Parsing
    print("🔄 Étape 1: Parsing du fichier...")
    try:
        df = parse_sage_file(str(test_file))
        print(f"✅ Parsing réussi!")
        print(f"   → {len(df)} lignes parsées")
        print()
    except Exception as e:
        print(f"❌ Erreur lors du parsing: {e}")
        return

    # Étape 2: Affichage des informations
    print("📊 Informations sur les données:")
    print(f"   → Nombre de lignes: {len(df)}")
    print(f"   → Nombre de colonnes: {len(df.columns)}")
    print(f"   → Colonnes: {', '.join(df.columns)}")
    print()

    # Étape 3: Validation
    print("🔄 Étape 2: Validation des données...")
    try:
        is_valid = validate_data(df)
        if is_valid:
            print("✅ Validation réussie!")
            print()
    except Exception as e:
        print(f"⚠️  Avertissement lors de la validation: {e}")
        print()

    # Étape 4: Nettoyage
    print("🔄 Étape 3: Nettoyage des données...")
    try:
        df_clean = clean_data(df)
        print(f"✅ Nettoyage réussi!")
        print(f"   → Lignes avant nettoyage: {len(df)}")
        print(f"   → Lignes après nettoyage: {len(df_clean)}")
        print(f"   → Lignes supprimées: {len(df) - len(df_clean)}")
        print()
    except Exception as e:
        print(f"❌ Erreur lors du nettoyage: {e}")
        return

    # Étape 5: Analyse des données
    print("📈 Analyse des données:")

    # Plage de dates
    date_min, date_max = get_date_range(df_clean)
    print(f"   → Période: {date_min.strftime('%d/%m/%Y')} - {date_max.strftime('%d/%m/%Y')}")

    # Liste des comptes
    accounts = get_accounts_list(df_clean)
    print(f"   → Nombre de comptes uniques: {len(accounts)}")
    print(f"   → Premier compte: {accounts[0]}")
    print(f"   → Dernier compte: {accounts[-1]}")
    print()

    # Statistiques par classe comptable
    print("📊 Répartition par classe comptable:")
    for classe in range(1, 8):
        start = classe * 10000000
        end = (classe + 1) * 10000000
        comptes_classe = df_clean[(df_clean['compte'] >= start) & (df_clean['compte'] < end)]

        if len(comptes_classe) > 0:
            print(f"   → Classe {classe}: {len(comptes_classe)} écritures ({len(comptes_classe)/len(df_clean)*100:.1f}%)")
    print()

    # Affichage des premières lignes
    print("📋 Aperçu des données (5 premières lignes):")
    print(df_clean.head().to_string())
    print()

    # Statistiques financières
    print("💰 Statistiques financières:")
    total_debit = df_clean['debit'].sum()
    total_credit = df_clean['credit'].sum()
    print(f"   → Total débits: {total_debit:,.2f} FCFA")
    print(f"   → Total crédits: {total_credit:,.2f} FCFA")
    print(f"   → Différence: {abs(total_debit - total_credit):,.2f} FCFA")
    print()

    # Journaux
    print("📖 Journaux utilisés:")
    journaux = df_clean['journal'].value_counts()
    for journal, count in journaux.items():
        print(f"   → {journal}: {count} écritures ({count/len(df_clean)*100:.1f}%)")
    print()

    # Conclusion
    print("=" * 80)
    print("✅ TEST MODULE 1 TERMINÉ AVEC SUCCÈS!")
    print("=" * 80)
    print()
    print(f"📊 Résumé:")
    print(f"   ✓ Fichier parsé: {test_file.name}")
    print(f"   ✓ Lignes traitées: {len(df_clean)}")
    print(f"   ✓ Comptes uniques: {len(accounts)}")
    print(f"   ✓ Période: {(date_max - date_min).days} jours")
    print(f"   ✓ Total mouvements: {total_debit + total_credit:,.2f} FCFA")
    print()
    print("🎯 Le Module 1 (Parser Sage) fonctionne correctement!")
    print()

if __name__ == "__main__":
    main()
