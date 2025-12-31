#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de test pour vérifier le fonctionnement des mappings de suivi d'activité
"""

import sys
from pathlib import Path

# Ajouter le chemin du module
sys.path.insert(0, str(Path(__file__).parent / "rapport_comptable"))

from modules.data_processor import (
    load_client_mapping,
    get_suivi_activite_categories,
    convert_client_mapping_to_legacy_format
)


def test_client_mapping(client_code: str):
    """Teste le chargement et la conversion d'un mapping client"""

    print(f"\n{'='*60}")
    print(f"Test du mapping pour : {client_code}")
    print('='*60)

    # 1. Charger le mapping JSON
    print(f"\n1. Chargement du mapping JSON...")
    mapping = load_client_mapping(client_code)

    if not mapping:
        print(f"   ❌ Échec du chargement du mapping pour '{client_code}'")
        return False

    print(f"   ✓ Mapping chargé : {mapping.get('client_name', client_code)}")

    # 2. Afficher les statistiques
    categories = mapping.get('categories', {})
    print(f"\n2. Statistiques du mapping :")
    print(f"   - Personnel : {len(categories.get('personnel', {}))} catégories")
    print(f"   - Charges   : {len(categories.get('charges', {}))} catégories")
    print(f"   - Produits  : {len(categories.get('produits', {}))} catégories")

    # 3. Afficher quelques exemples
    print(f"\n3. Exemples de catégories :")

    for cat_type in ['personnel', 'charges', 'produits']:
        if cat_type in categories and categories[cat_type]:
            print(f"\n   {cat_type.upper()} (3 premières) :")
            count = 0
            for key, data in categories[cat_type].items():
                if count >= 3:
                    break
                libelle = data.get('libelle', key)
                comptes = data.get('comptes', [])
                print(f"     - {libelle}")
                print(f"       Comptes: {', '.join(comptes)}")
                count += 1

    # 4. Tester la conversion en format legacy
    print(f"\n4. Conversion en format legacy...")
    legacy_mapping = convert_client_mapping_to_legacy_format(mapping)
    print(f"   ✓ {len(legacy_mapping)} catégories converties")

    # Afficher quelques exemples de conversion
    print(f"\n   Exemples de conversion :")
    count = 0
    for key, prefixes in legacy_mapping.items():
        if count >= 3:
            break
        print(f"     - {key}: {prefixes}")
        count += 1

    # 5. Tester get_suivi_activite_categories
    print(f"\n5. Test de get_suivi_activite_categories...")
    categories_list = get_suivi_activite_categories(client_code=client_code)

    print(f"   Personnel : {len(categories_list['personnel'])} catégories")
    print(f"   Charges   : {len(categories_list['charges'])} catégories")
    print(f"   Produits  : {len(categories_list['produits'])} catégories")

    # Afficher les libellés
    if categories_list['personnel']:
        print(f"\n   Catégories personnel (5 premières) :")
        for i, (key, libelle) in enumerate(categories_list['personnel'][:5]):
            print(f"     {i+1}. {libelle}")

    print(f"\n{'='*60}")
    print(f"✓ Test réussi pour {client_code}")
    print('='*60)

    return True


def main():
    """Fonction principale"""

    print("\n" + "="*60)
    print("TEST DES MAPPINGS DE SUIVI D'ACTIVITÉ")
    print("="*60)

    # Liste des clients à tester
    clients = [
        'blue_lease',
        'bit',
        'bcom',
        'blue_logistik_porthos',
        'go_cash_ventis'
    ]

    results = {}

    for client_code in clients:
        try:
            results[client_code] = test_client_mapping(client_code)
        except Exception as e:
            print(f"\n❌ Erreur lors du test de '{client_code}': {e}")
            import traceback
            traceback.print_exc()
            results[client_code] = False

    # Résumé
    print("\n" + "="*60)
    print("RÉSUMÉ DES TESTS")
    print("="*60)

    for client_code, success in results.items():
        status = "✓ OK" if success else "✗ ÉCHEC"
        print(f"  {client_code:30} {status}")

    total_success = sum(1 for s in results.values() if s)
    print(f"\n  Total: {total_success}/{len(clients)} tests réussis")
    print("="*60 + "\n")


if __name__ == '__main__':
    main()
