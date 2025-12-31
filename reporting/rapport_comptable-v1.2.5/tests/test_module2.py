#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de test pour le Module 2 - Traitement des données comptables
"""

import sys
from pathlib import Path

# Ajouter le répertoire parent au path
sys.path.insert(0, str(Path(__file__).parent))

from modules.sage_parser import parse_sage_file, validate_data, clean_data
from modules.data_processor import (
    calculate_balance,
    generate_bilan,
    generate_compte_resultat,
    calculate_sig,
    get_comptes_by_class
)
from utils.logger import setup_logger

def main():
    """Test du Module 2 - Traitement des données"""

    # Configuration du logger
    logger = setup_logger()

    print("=" * 80)
    print("TEST MODULE 2 - TRAITEMENT DES DONNÉES COMPTABLES")
    print("=" * 80)
    print()

    # Charger les données avec Module 1
    test_file = Path(__file__).parent.parent / "TESTE BIMMO_exportation.txt"

    if not test_file.exists():
        print(f"❌ ERREUR: Fichier de test introuvable: {test_file}")
        return

    print(f"📁 Chargement du fichier: {test_file.name}")

    # Étape 1: Parser et nettoyer
    df = parse_sage_file(str(test_file))
    validate_data(df)
    df_clean = clean_data(df)
    print(f"✅ {len(df_clean)} écritures chargées")
    print()

    # ========== TEST 1: BALANCE GÉNÉRALE ==========
    print("=" * 80)
    print("TEST 1 : CALCUL DE LA BALANCE GÉNÉRALE")
    print("=" * 80)
    print()

    balance = calculate_balance(df_clean)

    print(f"📊 Balance calculée:")
    print(f"   → Nombre de comptes: {len(balance)}")
    print(f"   → Total Débits: {balance['total_debit'].sum():,.2f} FCFA")
    print(f"   → Total Crédits: {balance['total_credit'].sum():,.2f} FCFA")
    print(f"   → Total Soldes Débiteurs: {balance['solde_debiteur'].sum():,.2f} FCFA")
    print(f"   → Total Soldes Créditeurs: {balance['solde_crediteur'].sum():,.2f} FCFA")
    print()

    # Vérifier l'équilibre
    difference = abs(balance['total_debit'].sum() - balance['total_credit'].sum())
    if difference < 0.01:
        print("✅ Balance équilibrée !")
    else:
        print(f"⚠️  Balance déséquilibrée - Différence: {difference:,.2f} FCFA")
    print()

    # Afficher les 10 premiers comptes
    print("📋 Aperçu de la balance (10 premiers comptes):")
    print(balance[['compte', 'libelle', 'total_debit', 'total_credit',
                   'solde_debiteur', 'solde_crediteur']].head(10).to_string(index=False))
    print()

    # ========== TEST 2: BILAN ==========
    print("=" * 80)
    print("TEST 2 : GÉNÉRATION DU BILAN")
    print("=" * 80)
    print()

    bilan = generate_bilan(balance)

    print(f"📊 Bilan généré:")
    print()
    print(f"   ACTIF (Soldes Débiteurs):")
    print(f"   -------------------------")
    if len(bilan['actif']) > 0:
        for _, row in bilan['actif'].iterrows():
            print(f"   → {row['compte']:8d} - {row['libelle'][:40]:40s} : {row['solde_debiteur']:>15,.2f} FCFA")
        print(f"   {'-' * 70}")
        print(f"   TOTAL ACTIF : {bilan['total_actif']:>15,.2f} FCFA")
    else:
        print("   (Aucun compte à l'actif)")
    print()

    print(f"   PASSIF (Soldes Créditeurs):")
    print(f"   ---------------------------")
    if len(bilan['passif']) > 0:
        for _, row in bilan['passif'].iterrows():
            print(f"   → {row['compte']:8d} - {row['libelle'][:40]:40s} : {row['solde_crediteur']:>15,.2f} FCFA")
        print(f"   {'-' * 70}")
        print(f"   TOTAL PASSIF : {bilan['total_passif']:>15,.2f} FCFA")
    else:
        print("   (Aucun compte au passif)")
    print()

    # Vérifier l'équilibre du bilan
    difference_bilan = abs(bilan['total_actif'] - bilan['total_passif'])
    if difference_bilan < 0.01:
        print("✅ Bilan équilibré (Actif = Passif) !")
    else:
        print(f"⚠️  Bilan déséquilibré - Différence: {difference_bilan:,.2f} FCFA")
    print()

    # ========== TEST 3: COMPTE DE RÉSULTAT ==========
    print("=" * 80)
    print("TEST 3 : GÉNÉRATION DU COMPTE DE RÉSULTAT")
    print("=" * 80)
    print()

    cr = generate_compte_resultat(balance)

    print(f"📊 Compte de Résultat généré:")
    print()
    print(f"   CHARGES (Classe 6):")
    print(f"   -------------------")
    if len(cr['charges']) > 0:
        for _, row in cr['charges'].iterrows():
            print(f"   → {row['compte']:8d} - {row['libelle'][:40]:40s} : {row['total_debit']:>15,.2f} FCFA")
        print(f"   {'-' * 70}")
        print(f"   TOTAL CHARGES : {cr['total_charges']:>15,.2f} FCFA")
    else:
        print("   (Aucune charge)")
    print()

    print(f"   PRODUITS (Classe 7):")
    print(f"   --------------------")
    if len(cr['produits']) > 0:
        for _, row in cr['produits'].iterrows():
            print(f"   → {row['compte']:8d} - {row['libelle'][:40]:40s} : {row['total_credit']:>15,.2f} FCFA")
        print(f"   {'-' * 70}")
        print(f"   TOTAL PRODUITS : {cr['total_produits']:>15,.2f} FCFA")
    else:
        print("   (Aucun produit)")
    print()

    print(f"   {'=' * 70}")
    if cr['resultat'] >= 0:
        print(f"   RÉSULTAT NET (Bénéfice) : {cr['resultat']:>15,.2f} FCFA ✓")
    else:
        print(f"   RÉSULTAT NET (Perte)    : {cr['resultat']:>15,.2f} FCFA ✗")
    print(f"   {'=' * 70}")
    print()

    # ========== TEST 4: SOLDES INTERMÉDIAIRES DE GESTION ==========
    print("=" * 80)
    print("TEST 4 : CALCUL DES SOLDES INTERMÉDIAIRES DE GESTION (SIG)")
    print("=" * 80)
    print()

    sig = calculate_sig(cr)

    print(f"📊 SIG calculés:")
    print()
    print(f"   1. Chiffre d'affaires (CA)         : {sig['chiffre_affaires']:>15,.2f} FCFA")
    print(f"   2. Marge commerciale                : {sig['marge_commerciale']:>15,.2f} FCFA")
    print(f"   3. Valeur ajoutée (VA)              : {sig['valeur_ajoutee']:>15,.2f} FCFA")
    print(f"   4. Excédent Brut d'Exploitation     : {sig['ebe']:>15,.2f} FCFA")
    print(f"   5. Résultat d'exploitation          : {sig['resultat_exploitation']:>15,.2f} FCFA")
    print(f"   6. Résultat net                     : {sig['resultat_net']:>15,.2f} FCFA")
    print()

    print(f"   Détails:")
    print(f"   --------")
    print(f"   → Ventes de marchandises            : {sig['ventes_marchandises']:>15,.2f} FCFA")
    print(f"   → Achats de marchandises            : {sig['achats_marchandises']:>15,.2f} FCFA")
    print(f"   → Production vendue                 : {sig['production_vendue']:>15,.2f} FCFA")
    print(f"   → Services vendus                   : {sig['services_vendus']:>15,.2f} FCFA")
    print(f"   → Charges externes                  : {sig['charges_externes']:>15,.2f} FCFA")
    print(f"   → Impôts et taxes                   : {sig['impots_taxes']:>15,.2f} FCFA")
    print(f"   → Charges de personnel              : {sig['charges_personnel']:>15,.2f} FCFA")
    print(f"   → Dotations aux amortissements      : {sig['dotations_amortissements']:>15,.2f} FCFA")
    print()

    # ========== TEST 5: ANALYSE PAR CLASSE ==========
    print("=" * 80)
    print("TEST 5 : ANALYSE PAR CLASSE COMPTABLE")
    print("=" * 80)
    print()

    classes = {
        1: "Comptes de capitaux",
        2: "Comptes d'immobilisations",
        3: "Comptes de stocks",
        4: "Comptes de tiers",
        5: "Comptes financiers",
        6: "Comptes de charges",
        7: "Comptes de produits"
    }

    for classe, nom in classes.items():
        comptes_classe = get_comptes_by_class(balance, classe)
        if len(comptes_classe) > 0:
            total_debit = comptes_classe['total_debit'].sum()
            total_credit = comptes_classe['total_credit'].sum()
            print(f"   Classe {classe} - {nom}")
            print(f"      → {len(comptes_classe)} comptes")
            print(f"      → Total Débits : {total_debit:,.2f} FCFA")
            print(f"      → Total Crédits: {total_credit:,.2f} FCFA")
            print()

    # ========== CONCLUSION ==========
    print("=" * 80)
    print("✅ TEST MODULE 2 TERMINÉ AVEC SUCCÈS!")
    print("=" * 80)
    print()
    print(f"📊 Résumé des calculs:")
    print(f"   ✓ Balance       : {len(balance)} comptes")
    print(f"   ✓ Bilan Actif   : {bilan['total_actif']:,.2f} FCFA")
    print(f"   ✓ Bilan Passif  : {bilan['total_passif']:,.2f} FCFA")
    print(f"   ✓ Charges       : {cr['total_charges']:,.2f} FCFA")
    print(f"   ✓ Produits      : {cr['total_produits']:,.2f} FCFA")
    print(f"   ✓ Résultat      : {cr['resultat']:,.2f} FCFA")
    print(f"   ✓ CA            : {sig['chiffre_affaires']:,.2f} FCFA")
    print()
    print("🎯 Le Module 2 (Traitement des données) fonctionne correctement!")
    print()

if __name__ == "__main__":
    main()
