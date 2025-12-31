#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Classifieur SYSCOHADA pour le Suivi d'Activité

Ce module classifie automatiquement les comptes selon le plan comptable SYSCOHADA
pour générer un suivi d'activité structuré et compréhensible.
"""

import logging

logger = logging.getLogger(__name__)


def get_syscohada_category(compte_num: int) -> dict:
    """
    Retourne la catégorie SYSCOHADA pour un numéro de compte

    Args:
        compte_num: Numéro de compte (8 chiffres)

    Returns:
        Dict avec 'section', 'categorie', 'sous_categorie', 'ordre'
    """
    # Convertir en string pour analyse
    compte_str = str(compte_num).zfill(8)

    # Extraire les 2 premiers chiffres (classe)
    classe = int(compte_str[:2])

    # Extraire les 3 premiers chiffres (sous-classe)
    sous_classe = int(compte_str[:3])

    # CLASSE 6: CHARGES
    if classe == 60:
        return {
            'section': 'charges',
            'categorie': 'Achats et variations de stocks',
            'sous_categorie': get_sous_categorie_60(sous_classe),
            'ordre': 10
        }
    elif classe == 61:
        return {
            'section': 'charges',
            'categorie': 'Transports',
            'sous_categorie': '',
            'ordre': 20
        }
    elif classe == 62:
        return {
            'section': 'charges',
            'categorie': 'Services extérieurs A',
            'sous_categorie': get_sous_categorie_62(sous_classe),
            'ordre': 30
        }
    elif classe == 63:
        return {
            'section': 'charges',
            'categorie': 'Services extérieurs B',
            'sous_categorie': get_sous_categorie_63(sous_classe),
            'ordre': 40
        }
    elif classe == 64:
        return {
            'section': 'charges',
            'categorie': 'Impôts et taxes',
            'sous_categorie': '',
            'ordre': 50
        }
    elif classe == 65:
        return {
            'section': 'charges',
            'categorie': 'Autres charges',
            'sous_categorie': get_sous_categorie_65(sous_classe),
            'ordre': 60
        }
    elif classe == 66:
        return {
            'section': 'personnel',
            'categorie': 'Charges de personnel',
            'sous_categorie': get_sous_categorie_66(sous_classe),
            'ordre': 5
        }
    elif classe == 67:
        return {
            'section': 'charges',
            'categorie': 'Frais financiers',
            'sous_categorie': '',
            'ordre': 70
        }
    elif classe == 68:
        return {
            'section': 'charges',
            'categorie': 'Dotations aux amortissements',
            'sous_categorie': '',
            'ordre': 80
        }
    elif classe == 69:
        return {
            'section': 'charges',
            'categorie': 'Impôts sur le résultat',
            'sous_categorie': '',
            'ordre': 90
        }

    # CLASSE 7: PRODUITS
    elif classe == 70:
        return {
            'section': 'produits',
            'categorie': 'Ventes',
            'sous_categorie': get_sous_categorie_70(sous_classe),
            'ordre': 100
        }
    elif classe == 71:
        return {
            'section': 'produits',
            'categorie': 'Subventions d\'exploitation',
            'sous_categorie': '',
            'ordre': 110
        }
    elif classe == 72:
        return {
            'section': 'produits',
            'categorie': 'Production immobilisée',
            'sous_categorie': '',
            'ordre': 120
        }
    elif classe == 73:
        return {
            'section': 'produits',
            'categorie': 'Variations de stocks',
            'sous_categorie': '',
            'ordre': 130
        }
    elif classe == 75:
        return {
            'section': 'produits',
            'categorie': 'Autres produits',
            'sous_categorie': '',
            'ordre': 140
        }
    elif classe == 77:
        return {
            'section': 'produits',
            'categorie': 'Revenus financiers',
            'sous_categorie': '',
            'ordre': 150
        }
    elif classe == 78:
        return {
            'section': 'produits',
            'categorie': 'Reprises sur amortissements',
            'sous_categorie': '',
            'ordre': 160
        }
    elif classe == 79:
        return {
            'section': 'produits',
            'categorie': 'Transferts de charges',
            'sous_categorie': '',
            'ordre': 170
        }

    # Par défaut (non classifié)
    else:
        return {
            'section': 'autres',
            'categorie': f'Classe {classe}',
            'sous_categorie': '',
            'ordre': 999
        }


def get_sous_categorie_60(sous_classe: int) -> str:
    """Sous-catégories pour la classe 60 (Achats)"""
    if sous_classe == 601:
        return "Achats de marchandises"
    elif sous_classe == 602:
        return "Achats de matières premières"
    elif sous_classe == 604:
        return "Achats stockés de matières et fournitures"
    elif sous_classe == 605:
        return "Autres achats"
    else:
        return ""


def get_sous_categorie_62(sous_classe: int) -> str:
    """Sous-catégories pour la classe 62 (Services extérieurs A)"""
    if sous_classe == 621:
        return "Sous-traitance"
    elif sous_classe == 622:
        return "Locations et charges locatives"
    elif sous_classe == 623:
        return "Redevances de crédit-bail"
    elif sous_classe == 624:
        return "Entretien, réparations et maintenance"
    elif sous_classe == 625:
        return "Primes d'assurances"
    elif sous_classe == 626:
        return "Études, recherches et documentation"
    elif sous_classe == 627:
        return "Publicité, publications, relations publiques"
    elif sous_classe == 628:
        return "Frais de télécommunications"
    else:
        return ""


def get_sous_categorie_63(sous_classe: int) -> str:
    """Sous-catégories pour la classe 63 (Services extérieurs B)"""
    if sous_classe == 631:
        return "Frais bancaires"
    elif sous_classe == 632:
        return "Rémunérations d'intermédiaires et de conseils"
    elif sous_classe == 633:
        return "Frais de formation du personnel"
    elif sous_classe == 634:
        return "Réceptions, réunions et missions"
    elif sous_classe == 635:
        return "Frais de conseil et d'assemblées"
    elif sous_classe == 636:
        return "Cotisations"
    elif sous_classe == 637:
        return "Rémunérations de personnel extérieur"
    elif sous_classe == 638:
        return "Autres charges externes"
    else:
        return ""


def get_sous_categorie_65(sous_classe: int) -> str:
    """Sous-catégories pour la classe 65 (Autres charges)"""
    if sous_classe == 651:
        return "Redevances pour concessions, brevets, licences"
    elif sous_classe == 652:
        return "Moins-values sur cessions d'immobilisations"
    elif sous_classe == 658:
        return "Charges diverses"
    else:
        return ""


def get_sous_categorie_66(sous_classe: int) -> str:
    """Sous-catégories pour la classe 66 (Charges de personnel)"""
    if sous_classe == 661:
        return "Rémunérations directes"
    elif sous_classe == 662:
        return "Rémunérations indirectes"
    elif sous_classe == 663:
        return "Charges sociales"
    elif sous_classe == 664:
        return "Charges sociales du dirigeant"
    elif sous_classe == 665:
        return "Charges de personnel non permanent"
    elif sous_classe == 668:
        return "Autres charges de personnel"
    else:
        return ""


def get_sous_categorie_70(sous_classe: int) -> str:
    """Sous-catégories pour la classe 70 (Ventes)"""
    if sous_classe == 701:
        return "Ventes de produits finis"
    elif sous_classe == 702:
        return "Ventes de produits intermédiaires"
    elif sous_classe == 703:
        return "Ventes de produits résiduels"
    elif sous_classe == 704:
        return "Travaux"
    elif sous_classe == 705:
        return "Études"
    elif sous_classe == 706:
        return "Prestations de services"
    elif sous_classe == 707:
        return "Produits accessoires"
    else:
        return ""


def classify_accounts_for_suivi(df) -> dict:
    """
    Classifie tous les comptes du dataframe selon SYSCOHADA
    et les regroupe par catégorie pour le suivi d'activité

    Args:
        df: DataFrame avec colonnes 'compte', 'libelle', 'mois_data'

    Returns:
        Dict avec structure pour le suivi d'activité
    """
    from collections import defaultdict

    # Structure: {section: {categorie: {comptes: [...]}}}
    structure = {
        'personnel': {},
        'charges': {},
        'produits': {}
    }

    # Grouper les comptes par catégorie
    categories_data = defaultdict(lambda: defaultdict(list))

    for _, row in df.iterrows():
        compte = row['compte']
        classification = get_syscohada_category(compte)

        section = classification['section']
        categorie = classification['categorie']
        sous_categorie = classification['sous_categorie']

        # Ignorer les comptes hors classe 6 et 7
        if section not in ['personnel', 'charges', 'produits']:
            continue

        # Clé de regroupement: utiliser sous-catégorie si disponible, sinon catégorie
        key = sous_categorie if sous_categorie else categorie

        categories_data[section][(categorie, sous_categorie, classification['ordre'])].append(row)

    # Convertir en structure finale
    for section in ['personnel', 'charges', 'produits']:
        structure[section] = {}

        # Trier par ordre
        sorted_categories = sorted(categories_data[section].items(), key=lambda x: x[0][2])

        for (categorie, sous_categorie, ordre), rows in sorted_categories:
            key = sous_categorie if sous_categorie else categorie

            structure[section][key] = {
                'libelle': key,
                'categorie_parent': categorie,
                'comptes': rows
            }

    return structure


def aggregate_by_category(df, mois_noms) -> dict:
    """
    Agrège les montants par catégorie SYSCOHADA avec une ligne par catégorie

    Args:
        df: DataFrame du GL avec colonnes 'compte', 'libelle', 'date', 'debit', 'credit'
        mois_noms: Liste des noms de mois

    Returns:
        Structure pour excel_generator
    """
    import pandas as pd

    # Ajouter mois
    df_copy = df[df['date'].notna()].copy()
    df_copy['mois_num'] = df_copy['date'].dt.month

    mois_dict = {
        1: 'Janvier', 2: 'Février', 3: 'Mars', 4: 'Avril',
        5: 'Mai', 6: 'Juin', 7: 'Juillet', 8: 'Août',
        9: 'Septembre', 10: 'Octobre', 11: 'Novembre', 12: 'Décembre'
    }

    # Filtrer classe 6 et 7
    df_charges = df_copy[df_copy['compte'].astype(str).str.startswith('6')].copy()
    df_produits = df_copy[df_copy['compte'].astype(str).str.startswith('7')].copy()

    # Fonction pour agréger
    def aggregate_section(df_section, is_produit=False):
        """Agrège une section par catégorie SYSCOHADA"""
        categories = {}

        for compte in df_section['compte'].unique():
            df_compte = df_section[df_section['compte'] == compte]
            classification = get_syscohada_category(compte)

            # Clé = sous-catégorie si disponible, sinon catégorie
            key = classification['sous_categorie'] if classification['sous_categorie'] else classification['categorie']

            # Initialiser la catégorie si nécessaire
            if key not in categories:
                categories[key] = {
                    'libelle': key,
                    'ordre': classification['ordre'],
                    'mois_data': {mois: 0 for mois in mois_dict.values()}
                }

            # Calculer les montants mensuels pour ce compte
            for mois_num in range(1, 13):
                mois_nom = mois_dict[mois_num]
                df_mois = df_compte[df_compte['mois_num'] == mois_num]

                if is_produit:
                    montant = df_mois['credit'].sum()
                else:
                    montant = -df_mois['debit'].sum()  # Négatif pour charges

                categories[key]['mois_data'][mois_nom] += montant

        # Convertir en liste triée par ordre
        return sorted(categories.values(), key=lambda x: x['ordre'])

    # Séparer personnel et autres charges
    df_personnel = df_charges[df_charges['compte'].astype(str).str.startswith('66')].copy()
    df_autres_charges = df_charges[~df_charges['compte'].astype(str).str.startswith('66')].copy()

    return {
        'personnel': aggregate_section(df_personnel, is_produit=False),
        'charges': aggregate_section(df_autres_charges, is_produit=False),
        'produits': aggregate_section(df_produits, is_produit=True)
    }
