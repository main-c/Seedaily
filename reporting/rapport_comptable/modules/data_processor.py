#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Module de traitement des données comptables

Ce module gère:
- Le calcul de la balance générale
- La génération des synthèses comptables (bilan, compte de résultat)
- Le calcul des Soldes Intermédiaires de Gestion (SIG)
- La préparation des données pour le suivi d'activité
"""

import pandas as pd
import logging
import re
import json
from pathlib import Path
from typing import Dict, List, Tuple, Set, Optional
import sys

# Importer la configuration
sys.path.insert(0, str(Path(__file__).parent.parent))
from config import get_bilan_actif_regles, get_bilan_passif_regles, get_cr_charges_regles, get_cr_produits_regles, RegleCorrespondance

logger = logging.getLogger(__name__)


def calculate_balance(df: pd.DataFrame) -> pd.DataFrame:
    """
    Agrège les écritures par compte et calcule les soldes

    Args:
        df: DataFrame du Grand Livre

    Returns:
        DataFrame de la balance avec colonnes: compte, libelle, total_debit, total_credit, solde
    """
    logger.info("Calcul de la balance générale")

    # Grouper par compte
    balance = df.groupby('compte').agg({
        'libelle': 'first',  # Prendre le premier libellé
        'debit': 'sum',
        'credit': 'sum'
    }).reset_index()

    # Renommer les colonnes
    balance.columns = ['compte', 'libelle', 'total_debit', 'total_credit']

    # Calculer le solde (débit - crédit)
    balance['solde'] = balance['total_debit'] - balance['total_credit']

    # Déterminer le sens du solde
    balance['solde_debiteur'] = balance['solde'].apply(lambda x: x if x > 0 else 0)
    balance['solde_crediteur'] = balance['solde'].apply(lambda x: -x if x < 0 else 0)

    logger.info(f"Balance calculée: {len(balance)} comptes")

    return balance


def calculate_sig(compte_resultat: Dict) -> Dict:
    """
    Calcule les Soldes Intermédiaires de Gestion (SIG) selon SYSCOHADA

    Les SIG permettent d'analyser la formation du résultat par étapes successives.

    Args:
        compte_resultat: Dictionnaire du compte de résultat (nouvelle structure avec listes)

    Returns:
        Dictionnaire des SIG
    """
    logger.info("Calcul des Soldes Intermédiaires de Gestion")

    # Récupérer les catégories (maintenant ce sont des listes de dict)
    charges_list = compte_resultat['charges']
    produits_list = compte_resultat['produits']

    # Helper function pour trouver un montant par libellé (avec matching partiel)
    def find_montant(data_list: List[Dict], search_key: str) -> float:
        """Trouve le montant d'un poste par son libellé (case-insensitive, partial match)"""
        search_key_lower = search_key.lower()
        for item in data_list:
            if search_key_lower in item['poste'].lower():
                return item['montant']
        return 0.0

    # SIG selon SYSCOHADA (simplifié)

    # 1. Marge commerciale = Ventes marchandises - Achats marchandises
    ventes_marchandises = find_montant(produits_list, 'Ventes de marchandises')
    achats_marchandises = find_montant(charges_list, 'Achats de marchandises')

    # 2. Production vendue = Produits accessoires (707)
    production_vendue = find_montant(produits_list, 'Produit accessoirs')

    # 3. Services vendus
    services_vendus = find_montant(produits_list, 'Travaux, service vendus')

    # 4. Autres produits
    autres_produits = find_montant(produits_list, 'Autres produits') + find_montant(produits_list, 'Subvention')

    # 5. Charges externes = Transports + Services extérieurs
    transports = find_montant(charges_list, 'Transports')
    services_exterieurs = find_montant(charges_list, 'Services exterieurs')
    charges_externes = transports + services_exterieurs

    # 6. Impôts et taxes
    impots_taxes = find_montant(charges_list, 'Impots')

    # 7. Charges de personnel
    charges_personnel = find_montant(charges_list, 'Charges du personnel')

    # 8. Dotations aux amortissements
    dotations_amortissements = find_montant(charges_list, 'Dotations aux amortissements')

    # 9. Autres charges
    autres_charges = find_montant(charges_list, 'Autres charges')

    # 10. Frais financiers
    frais_financiers = find_montant(charges_list, 'Frais financiers')

    # Calcul des SIG

    # 1. Marge commerciale
    marge_commerciale = ventes_marchandises - achats_marchandises

    # 2. Chiffre d'affaires
    chiffre_affaires = ventes_marchandises + production_vendue + services_vendus

    # 3. Valeur ajoutée
    valeur_ajoutee = chiffre_affaires + autres_produits - achats_marchandises - charges_externes

    # 4. Excédent Brut d'Exploitation (EBE)
    ebe = valeur_ajoutee - impots_taxes - charges_personnel

    # 5. Résultat d'exploitation
    resultat_exploitation = ebe - dotations_amortissements

    # 6. Résultat net
    resultat_net = compte_resultat['resultat']

    sig = {
        'marge_commerciale': marge_commerciale,
        'chiffre_affaires': chiffre_affaires,
        'valeur_ajoutee': valeur_ajoutee,
        'ebe': ebe,
        'resultat_exploitation': resultat_exploitation,
        'resultat_net': resultat_net,
        'ventes_marchandises': ventes_marchandises,
        'achats_marchandises': achats_marchandises,
        'production_vendue': production_vendue,
        'services_vendus': services_vendus,
        'charges_externes': charges_externes,
        'impots_taxes': impots_taxes,
        'charges_personnel': charges_personnel,
        'dotations_amortissements': dotations_amortissements,
        'services_exterieurs': services_exterieurs,
        'autres_charges': autres_charges,
        'frais_financiers': frais_financiers
    }

    logger.info(f"SIG calculés - CA: {chiffre_affaires:,.2f} | EBE: {ebe:,.2f} | Résultat net: {resultat_net:,.2f}")

    return sig


def get_available_clients() -> Dict[str, str]:
    """
    Récupère la liste des clients disponibles avec leurs mappings

    Returns:
        Dictionnaire {client_name: client_code}
        Ex: {"BLUE LEASE": "blue_lease", "BIT": "bit", ...}
    """
    config_dir = Path(__file__).parent.parent / "config" / "suivi_activite_mappings"

    if not config_dir.exists():
        logger.warning(f"Répertoire de mappings non trouvé: {config_dir}")
        return {}

    clients = {}

    # Parcourir tous les fichiers JSON dans le répertoire
    for mapping_file in config_dir.glob("*.json"):
        try:
            with open(mapping_file, 'r', encoding='utf-8') as f:
                mapping = json.load(f)
                client_name = mapping.get('client_name', '')
                client_code = mapping_file.stem  # Nom du fichier sans extension

                if client_name:
                    clients[client_name] = client_code
                    logger.debug(f"Client trouvé: {client_name} -> {client_code}")
        except Exception as e:
            logger.warning(f"Erreur lors de la lecture de {mapping_file.name}: {e}")
            continue

    logger.info(f"{len(clients)} clients disponibles avec mapping personnalisé")
    return clients


def get_client_code_from_name(client_name: str) -> Optional[str]:
    """
    Trouve le code client correspondant au nom du client

    Args:
        client_name: Nom du client (ex: "BLUE LEASE", "BIT", etc.)

    Returns:
        Code du client (ex: "blue_lease", "bit") ou None si non trouvé
    """
    if not client_name:
        return None

    available_clients = get_available_clients()

    # Recherche exacte (insensible à la casse)
    for name, code in available_clients.items():
        if name.upper().strip() == client_name.upper().strip():
            logger.info(f"Client trouvé: '{client_name}' -> code '{code}'")
            return code

    logger.info(f"Pas de mapping spécifique pour le client '{client_name}' - utilisation du mapping par défaut")
    return None


def load_client_mapping(client_code: Optional[str] = None) -> Optional[Dict]:
    """
    Charge le mapping de suivi d'activité pour un client spécifique

    Args:
        client_code: Code du client (ex: 'blue_lease', 'bit', 'bcom', etc.)

    Returns:
        Dictionnaire du mapping ou None si non trouvé
    """
    if not client_code:
        return None

    # Chemin vers le fichier de mapping
    config_dir = Path(__file__).parent.parent / "config" / "suivi_activite_mappings"
    mapping_file = config_dir / f"{client_code}.json"

    if not mapping_file.exists():
        logger.warning(f"Fichier de mapping non trouvé pour le client '{client_code}': {mapping_file}")
        return None

    try:
        with open(mapping_file, 'r', encoding='utf-8') as f:
            mapping = json.load(f)
        logger.info(f"Mapping chargé pour le client '{client_code}': {mapping.get('client_name', client_code)}")
        return mapping
    except Exception as e:
        logger.error(f"Erreur lors du chargement du mapping pour '{client_code}': {e}")
        return None


def get_default_mapping() -> Dict:
    """
    Retourne le mapping par défaut (générique) pour le suivi d'activité

    Returns:
        Dictionnaire du mapping par défaut
    """
    return {
        # ============================
        # CHARGES DE PERSONNEL (compte 66)
        # ============================
        'Appointements': ['6611'],
        'Indemnite_transport': ['6612'],
        'Indemnite_logement': ['6613'],
        'Indemnite_responsabilite': ['6614'],
        'Indemnite_representation': ['6614'],  # Même compte que responsabilité
        'Indemnite_vehicule': ['6612'],  # Regroupé avec transport
        'Indemnite_blanchissage': ['6612'],  # Regroupé avec primes diverses
        'Primes_fonction': ['6615'],
        'Primes_panier': ['6612'],  # Primes de repas
        'Primes_vestimentaire': ['6612'],
        'Primes_anciennete': ['6615'],
        'Prime_assiduite': ['6615'],
        'Conges': ['6616'],
        'Cotisations_patronales': ['664'],
        'Appoint_du_mois': ['6611'],  # Régularisations de salaires
        'Pharmacie': ['6617'],  # Médecine du travail
        'Assurance_maladie': ['664'],  # Charges sociales

        # ============================
        # AUTRES CHARGES
        # ============================
        'Matieres_consommables': ['604'],
        'Fournitures_bureau': ['6041', '6057'],
        'Eau_electricite': ['6052', '6053'],
        'Carburant': ['6061'],
        'Transports': ['61'],
        'Telecommunication': ['6262', '6263'],
        'Entretien': ['6226'],  # Entretien et réparations
        'Formation': ['6228'],  # Frais de formation
        'Restauration': ['6247'],  # Frais de réception/restauration
        'Location_materiel': ['6222'],  # Locations mobilières
        'Loyer': ['6221'],
        'Assurance_risque': ['616'],  # Primes d'assurance
        'Publicite': ['627'],
        'Impots_taxes': ['64'],
        'Intermediaire_conseils': ['622', '6324'],
        'Frais_bancaires': ['631'],
        'Redevances_logiciels': ['6263'],  # Redevances/licences
        'Reception': ['6247'],  # Frais de réception
        'Interets_emprunt': ['671'],  # Intérêts des emprunts
        'Amortissement': ['68'],
        'Frais_mission': ['625'],  # Déplacements, missions
        'Penalites': ['658'],  # Charges diverses de gestion
        'Autres_charges_divers': ['658'],

        # ============================
        # PRODUITS
        # ============================
        'CA_commissions': ['707'],  # Commissions et courtages (loyers)
        'CA_autres': ['701', '702', '703', '704', '705', '706', '709'],  # Autres ventes (EXCLUANT 707 et 708)
        'Autres_produits': ['708', '71']  # Produits accessoires + subventions
    }


def convert_client_mapping_to_legacy_format(client_mapping: Dict) -> Dict:
    """
    Convertit le mapping client (nouveau format JSON) en format legacy (ancien format)

    Args:
        client_mapping: Mapping client au format JSON

    Returns:
        Mapping au format legacy (compatible avec l'ancien code)
    """
    legacy_mapping = {}

    categories = client_mapping.get('categories', {})

    # Parcourir toutes les catégories (personnel, charges, produits)
    for category_type, category_items in categories.items():
        for key, data in category_items.items():
            comptes = data.get('comptes', [])

            # Convertir les comptes de 8 chiffres en préfixes
            # Exemple: 66110000 -> 6611
            prefixes = []
            for compte in comptes:
                # Enlever les zéros de fin pour obtenir le préfixe
                compte_str = str(compte).rstrip('0')
                if not compte_str:
                    compte_str = str(compte)[:4]  # Garder au moins 4 chiffres
                prefixes.append(compte_str)

            legacy_mapping[key] = prefixes

    return legacy_mapping


def prepare_suivi_activite_detaille(df: pd.DataFrame, client_code: Optional[str] = None) -> Dict:
    """
    Prépare le tableau de suivi budgétaire mensuel détaillé par compte

    APPROCHE DIRECTE: Lit directement le GL sans mapping statique
    Liste tous les mouvements avec regroupement intelligent des entrées similaires

    Args:
        df: DataFrame du Grand Livre
        client_code: Code du client (non utilisé dans cette version)

    Returns:
        Dictionnaire avec structure:
        {
            'personnel': {'groups': [...]},
            'charges': {'groups': [...]},
            'produits': {'groups': [...]}
        }
        Chaque group contient:
        - 'libelle': libellé de l'entrée (sans numéro de compte)
        - 'mois_data': {mois: montant}
        - 'is_subtotal': True si c'est un sous-total
        - 'entries': liste des entrées regroupées (si c'est un groupe)
    """
    logger.info("Préparation du suivi budgétaire DÉTAILLÉ - Classification SYSCOHADA")

    # Utiliser le classifieur SYSCOHADA
    from modules.syscohada_classifier import aggregate_by_category

    mois_noms = [
        'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
        'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ]

    result = aggregate_by_category(df, mois_noms)

    # Compter pour les logs
    nb_personnel = len(result.get('personnel', []))
    nb_charges = len(result.get('charges', []))
    nb_produits = len(result.get('produits', []))

    logger.info(f"Classification SYSCOHADA: {nb_personnel} catégories personnel, {nb_charges} catégories charges, {nb_produits} catégories produits")
    return result


def prepare_suivi_activite(df: pd.DataFrame, client_code: Optional[str] = None) -> Dict:
    """
    Prépare le tableau de suivi budgétaire mensuel par catégories

    Ce tableau permet de suivre l'évolution mensuelle des charges et produits
    par grandes catégories budgétaires (Personnel, Charges externes, CA, etc.)

    Args:
        df: DataFrame du Grand Livre
        client_code: Code du client pour charger son mapping spécifique (optionnel)

    Returns:
        Dictionnaire avec les données mensuelles par catégorie
    """
    if client_code:
        logger.info(f"Préparation du tableau de suivi budgétaire pour le client: {client_code}")
    else:
        logger.info("Préparation du tableau de suivi budgétaire (mapping par défaut)")

    # Charger le mapping approprié
    categorie_mapping = None

    if client_code:
        # Charger le mapping client
        client_mapping = load_client_mapping(client_code)
        if client_mapping:
            categorie_mapping = convert_client_mapping_to_legacy_format(client_mapping)
            logger.info(f"Mapping client chargé: {len(categorie_mapping)} catégories")

    # Si pas de mapping client, utiliser le mapping par défaut
    if not categorie_mapping:
        categorie_mapping = get_default_mapping()
        logger.info(f"Utilisation du mapping par défaut: {len(categorie_mapping)} catégories")

    # Filtrer les lignes avec date valide
    df_copy = df[df['date'].notna()].copy()

    # Extraire le mois (format: 'Janvier', 'Février', etc.)
    df_copy['mois_num'] = df_copy['date'].dt.month
    df_copy['annee'] = df_copy['date'].dt.year

    # Noms des mois en français
    mois_noms = {
        1: 'Janvier', 2: 'Février', 3: 'Mars', 4: 'Avril',
        5: 'Mai', 6: 'Juin', 7: 'Juillet', 8: 'Août',
        9: 'Septembre', 10: 'Octobre', 11: 'Novembre', 12: 'Décembre'
    }

    # Initialiser le dictionnaire de résultat
    # Structure: {categorie: {mois: montant}}
    result = {}

    # Pour chaque catégorie, calculer les montants mensuels
    for categorie, prefixes in categorie_mapping.items():
        result[categorie] = {}

        for mois_num in range(1, 13):
            mois_nom = mois_noms[mois_num]
            montant = 0

            # Filtrer par mois
            df_mois = df_copy[df_copy['mois_num'] == mois_num]

            # Pour chaque préfixe de compte
            for prefix in prefixes:
                # Convertir le préfixe en numéro de compte (ajouter des zéros)
                prefix_num = int(prefix.ljust(8, '0'))
                prefix_next = int(str(int(prefix) + 1).ljust(8, '0'))

                # Filtrer les comptes correspondants
                comptes_matches = df_mois[
                    (df_mois['compte'] >= prefix_num) &
                    (df_mois['compte'] < prefix_next)
                ]

                # Pour les charges: sommer les débits (positif = dépense)
                # Pour les produits: sommer les crédits (positif = revenu)
                if categorie.startswith('CA_') or categorie == 'Autres_produits':
                    # PRODUITS: crédits
                    montant += comptes_matches['credit'].sum()
                else:
                    # CHARGES: débits (on les met en négatif pour affichage)
                    montant -= comptes_matches['debit'].sum()

            result[categorie][mois_nom] = montant

    logger.info(f"Tableau de suivi budgétaire préparé: {len(result)} catégories")

    return result


def get_suivi_activite_categories(client_code: Optional[str] = None) -> Dict:
    """
    Récupère la liste des catégories du suivi d'activité organisées par type

    Args:
        client_code: Code du client (optionnel)

    Returns:
        Dictionnaire avec les catégories organisées par type:
        {
            'personnel': [(key, libelle), ...],
            'charges': [(key, libelle), ...],
            'produits': [(key, libelle), ...]
        }
    """
    result = {
        'personnel': [],
        'charges': [],
        'produits': []
    }

    # Charger le mapping approprié
    if client_code:
        client_mapping = load_client_mapping(client_code)
        if client_mapping:
            # Utiliser le mapping client
            categories = client_mapping.get('categories', {})

            for category_type in ['personnel', 'charges', 'produits']:
                if category_type in categories:
                    for key, data in categories[category_type].items():
                        libelle = data.get('libelle', key)
                        result[category_type].append((key, libelle))

            return result

    # Sinon, utiliser le mapping par défaut
    # Construire à partir du mapping legacy
    default_mapping = get_default_mapping()

    # Définir les clés connues par type
    personnel_keys = [
        'Appointements', 'Indemnite_transport', 'Indemnite_logement',
        'Indemnite_responsabilite', 'Indemnite_representation', 'Indemnite_vehicule',
        'Indemnite_blanchissage', 'Primes_fonction', 'Primes_panier',
        'Primes_vestimentaire', 'Primes_anciennete', 'Prime_assiduite',
        'Conges', 'Cotisations_patronales', 'Appoint_du_mois',
        'Pharmacie', 'Assurance_maladie'
    ]

    charges_keys = [
        'Matieres_consommables', 'Fournitures_bureau', 'Eau_electricite',
        'Carburant', 'Transports', 'Telecommunication', 'Entretien',
        'Formation', 'Restauration', 'Location_materiel', 'Loyer',
        'Assurance_risque', 'Publicite', 'Impots_taxes',
        'Intermediaire_conseils', 'Frais_bancaires', 'Redevances_logiciels',
        'Reception', 'Interets_emprunt', 'Amortissement',
        'Frais_mission', 'Penalites', 'Autres_charges_divers'
    ]

    produits_keys = [
        'CA_commissions', 'CA_autres', 'Autres_produits'
    ]

    # Mapper les clés aux libellés par défaut
    default_labels = {
        'Appointements': 'Appoitements',
        'Indemnite_transport': 'Indemnité de transport',
        'Indemnite_logement': 'Indemnité de logement',
        'Indemnite_responsabilite': 'Indemnité de responsabilité',
        'Indemnite_representation': 'Indemnité de représentation',
        'Indemnite_vehicule': 'Indemnité véhicule',
        'Indemnite_blanchissage': 'Indemnité de blanchissage',
        'Primes_fonction': 'Primes fonction',
        'Primes_panier': 'Primes panier',
        'Primes_vestimentaire': 'Primes vestimentaire',
        'Primes_anciennete': 'Primes d\'ancienneté',
        'Prime_assiduite': 'Prime d\'assiduité',
        'Conges': 'Congés',
        'Cotisations_patronales': 'Cotisations patronales',
        'Appoint_du_mois': 'Appoint du mois',
        'Pharmacie': 'Pharmacie',
        'Assurance_maladie': 'Assurance maladie',
        'Matieres_consommables': 'Matières consommables',
        'Fournitures_bureau': 'Fournitures de bureau',
        'Eau_electricite': 'Eau/Électricité',
        'Carburant': 'Carburant',
        'Transports': 'Transports',
        'Telecommunication': 'Télécommunication',
        'Entretien': 'Entretien',
        'Formation': 'Formation',
        'Restauration': 'Restauration',
        'Location_materiel': 'Location matériel',
        'Loyer': 'Loyer',
        'Assurance_risque': 'Assurance risque',
        'Publicite': 'Publicité',
        'Impots_taxes': 'Impôts & Taxes',
        'Intermediaire_conseils': 'Intermédiaire & conseils',
        'Frais_bancaires': 'Frais bancaires',
        'Redevances_logiciels': 'Redevances logiciels',
        'Reception': 'Réception',
        'Interets_emprunt': 'Intérêts emprunt',
        'Amortissement': 'Amortissement',
        'Frais_mission': 'Frais de mission',
        'Penalites': 'Pénalités',
        'Autres_charges_divers': 'Autres charges divers',
        'CA_commissions': 'Chiffre d\'affaires commissions',
        'CA_autres': 'Chiffre d\'affaires',
        'Autres_produits': 'Autres produits'
    }

    # Construire les catégories par défaut
    for key in personnel_keys:
        if key in default_mapping:
            result['personnel'].append((key, default_labels.get(key, key)))

    for key in charges_keys:
        if key in default_mapping:
            result['charges'].append((key, default_labels.get(key, key)))

    for key in produits_keys:
        if key in default_mapping:
            result['produits'].append((key, default_labels.get(key, key)))

    return result


def get_top_comptes(balance: pd.DataFrame, n: int = 10, by: str = 'debit') -> pd.DataFrame:
    """
    Retourne les N comptes avec le plus de mouvements

    Args:
        balance: DataFrame de la balance
        n: Nombre de comptes à retourner
        by: Critère de tri ('debit', 'credit', 'solde')

    Returns:
        DataFrame des top comptes
    """
    if by == 'debit':
        return balance.nlargest(n, 'total_debit')
    elif by == 'credit':
        return balance.nlargest(n, 'total_credit')
    elif by == 'solde':
        return balance.nlargest(n, 'solde_debiteur')
    else:
        raise ValueError(f"Critère invalide: {by}")


def get_comptes_by_class(balance: pd.DataFrame, classe: int) -> pd.DataFrame:
    """
    Filtre les comptes par classe comptable

    Args:
        balance: DataFrame de la balance
        classe: Numéro de classe (1-8)

    Returns:
        DataFrame filtré
    """
    start = classe * 10000000
    end = (classe + 1) * 10000000

    return balance[(balance['compte'] >= start) & (balance['compte'] < end)]


# ============================
# NOUVELLES FONCTIONS POUR BILAN/CR SYNTHETIQUE AVEC CORRESPONDANCES
# ============================

def parse_account_radicals(radical_str: str) -> List[str]:
    """
    Parse une chaîne de radicaux de comptes et retourne la liste des radicaux individuels

    Exemples de formats supportés:
    - "21" → ["21"]
    - "101 à 104" → ["101", "102", "103", "104"]
    - "22 à 25" → ["22", "23", "24", "25"]
    - "281 - 291" → ["281", "291"]
    - "282 à 284-291 à 295" → ["282", "283", "284", "291", "292", "293", "294", "295"]
    - "42.43" → ["42", "43"]
    - "52, 53, 55, 56,57" → ["52", "53", "55", "56", "57"]
    - "40(SAUF 409)" → ["40"] (gestion des exclusions faite ailleurs)
    - "52 SODLE POSITIF" → ["52"] (gestion des conditions faite ailleurs)

    Args:
        radical_str: Chaîne contenant les radicaux de comptes

    Returns:
        Liste des radicaux de comptes (sous forme de strings)
    """
    if pd.isna(radical_str) or not isinstance(radical_str, str):
        return []

    # Nettoyer la chaîne: enlever les conditions (SOLDE, SAUF, etc.)
    radical_str = re.sub(r'\s+(SOLDE|SODLE)\s+(POSITIF|NEGATIF)', '', radical_str, flags=re.IGNORECASE)
    radical_str = re.sub(r'\(SAUF\s+\d+\)', '', radical_str)
    radical_str = radical_str.strip()

    if not radical_str:
        return []

    result = []

    # Séparer par tirets simples (pour les groupes multiples comme "282 à 284-291 à 295")
    groups = re.split(r'\s*-\s*(?=\d)', radical_str)

    for group in groups:
        # Cas 1: Plage avec "à" (ex: "101 à 104", "22 à 25")
        if ' à ' in group or ' a ' in group:
            match = re.search(r'(\d+)\s+[àa]\s+(\d+)', group)
            if match:
                start = match.group(1)
                end = match.group(2)

                # Générer tous les nombres entre start et end
                start_num = int(start)
                end_num = int(end)

                for num in range(start_num, end_num + 1):
                    # Conserver le même nombre de chiffres que le début
                    result.append(str(num).zfill(len(start)))

        # Cas 2: Liste avec virgules ou points (ex: "52, 53, 55" ou "42.43")
        elif ',' in group or '.' in group:
            # Remplacer les points par des virgules puis split
            items = re.split(r'[,.\s]+', group)
            for item in items:
                item = item.strip()
                if item and item.isdigit():
                    result.append(item)

        # Cas 3: Radical simple (ex: "21", "601")
        else:
            # Extraire juste le nombre
            match = re.search(r'(\d+)', group)
            if match:
                result.append(match.group(1))

    return result


def extract_conditions(radical_str: str) -> Tuple[List[str], List[str], str]:
    """
    Extrait les radicaux, les exclusions et les conditions de solde d'une chaîne

    Args:
        radical_str: Chaîne contenant les radicaux de comptes

    Returns:
        Tuple (radicaux, exclusions, condition_solde)
        - radicaux: liste des radicaux de comptes
        - exclusions: liste des radicaux à exclure (ex: ["409"])
        - condition_solde: "POSITIF", "NEGATIF", ou "" si pas de condition
    """
    if pd.isna(radical_str) or not isinstance(radical_str, str):
        return [], [], ""

    exclusions = []
    condition_solde = ""

    # Extraire les exclusions (SAUF)
    sauf_match = re.search(r'\(SAUF\s+(\d+)\)', radical_str, flags=re.IGNORECASE)
    if sauf_match:
        exclusions.append(sauf_match.group(1))

    # Extraire la condition de solde
    if re.search(r'\s+SOLDE\s+POSITIF', radical_str, flags=re.IGNORECASE) or \
       re.search(r'\s+SODLE\s+POSITIF', radical_str, flags=re.IGNORECASE):
        condition_solde = "POSITIF"
    elif re.search(r'\s+SOLDE\s+NEGATIF', radical_str, flags=re.IGNORECASE) or \
         re.search(r'\s+SODLE\s+NEGATIF', radical_str, flags=re.IGNORECASE):
        condition_solde = "NEGATIF"

    # Parser les radicaux
    radicaux = parse_account_radicals(radical_str)

    return radicaux, exclusions, condition_solde


def match_accounts_by_radicals(
    balance: pd.DataFrame,
    radicaux: List[str],
    exclusions: List[str] = None,
    condition_solde: str = ""
) -> pd.DataFrame:
    """
    Trouve tous les comptes de la balance qui correspondent aux radicaux donnés

    Args:
        balance: DataFrame de la balance
        radicaux: Liste des radicaux de comptes (ex: ["101", "102", "103"])
        exclusions: Liste des radicaux à exclure (ex: ["409"])
        condition_solde: "POSITIF" (solde débiteur), "NEGATIF" (solde créditeur), ou ""

    Returns:
        DataFrame filtré contenant uniquement les comptes correspondants
    """
    if not radicaux:
        return pd.DataFrame()

    if exclusions is None:
        exclusions = []

    # Convertir les comptes en string pour le matching par préfixe
    balance_copy = balance.copy()
    balance_copy['compte_str'] = balance_copy['compte'].astype(str)

    # Filtrer par radicaux (matching par préfixe)
    mask = pd.Series([False] * len(balance_copy), index=balance_copy.index)

    for radical in radicaux:
        # Un compte correspond si son numéro commence par le radical
        radical_mask = balance_copy['compte_str'].str.startswith(radical)
        mask |= radical_mask

    # Appliquer les exclusions
    for exclusion in exclusions:
        exclusion_mask = balance_copy['compte_str'].str.startswith(exclusion)
        mask &= ~exclusion_mask

    filtered = balance_copy[mask]

    # Appliquer la condition de solde si nécessaire
    if condition_solde == "POSITIF":
        # Solde positif = solde débiteur
        filtered = filtered[filtered['solde'] > 0]
    elif condition_solde == "NEGATIF":
        # Solde négatif = solde créditeur
        filtered = filtered[filtered['solde'] < 0]

    return filtered


def generate_bilan_synthetique(
    balance: pd.DataFrame,
    resultat_net: float = 0
) -> Dict:
    """
    Génère le bilan synthétique selon l'algorithme comptable correct:

    ALGORITHME:
    1. Pour chaque compte: Solde = Total Débit - Total Crédit
    2. Classification selon la NATURE du compte et le SIGNE du solde:
       - Solde > 0 (Débiteur) → Généralement ACTIF
       - Solde < 0 (Créditeur) → Généralement PASSIF
    3. Exceptions:
       - Amortissements (28x): Solde créditeur mais ACTIF en négatif
       - Comptes de trésorerie (52, 53, 55, 57): Selon condition POSITIF/NEGATIF
       - Comptes de tiers (4x): Peuvent être ACTIF ou PASSIF selon le solde

    Args:
        balance: DataFrame de la balance générale (avec colonne 'solde' = débit - crédit)
        resultat_net: Résultat net de l'exercice (à inclure au passif si > 0, actif si < 0)

    Returns:
        Dictionnaire structuré avec ACTIF et PASSIF
    """
    logger.info("Génération du bilan synthétique selon l'algorithme comptable")

    actif_data = []
    passif_data = []

    # ÉTAPE 1: Traiter l'ACTIF
    for regle in get_bilan_actif_regles():
        # Trouver les comptes correspondants
        comptes_matched = match_accounts_by_radicals(
            balance,
            regle.prefixes,
            regle.exclusions,
            regle.condition_solde
        )

        if len(comptes_matched) == 0:
            montant = 0.0
        else:
            # LOGIQUE: Pour l'ACTIF, on prend le SOLDE BRUT (Débit - Crédit)
            # - Si solde > 0 (débiteur): normal, montant positif à l'actif
            # - Si solde < 0 (créditeur):
            #   * Amortissements: montant négatif en déduction des immobilisations
            #   * Autres: anormal mais on le prend quand même
            montant = comptes_matched['solde'].sum()

        actif_data.append({
            'poste': regle.libelle,
            'radicaux': ', '.join(regle.prefixes),
            'montant': montant
        })

    # ÉTAPE 2: Traiter le PASSIF
    for regle in get_bilan_passif_regles():
        # Trouver les comptes correspondants
        comptes_matched = match_accounts_by_radicals(
            balance,
            regle.prefixes,
            regle.exclusions,
            regle.condition_solde
        )

        if len(comptes_matched) == 0:
            montant = 0.0
        else:
            # LOGIQUE: Pour le PASSIF, on prend l'OPPOSÉ du SOLDE
            # Car un solde créditeur (négatif) représente une dette
            # Solde = Débit - Crédit (sera négatif pour les dettes)
            # Montant au passif = abs(Solde) = Crédit - Débit
            solde_total = comptes_matched['solde'].sum()

            # On prend la valeur absolue si négatif (normal), sinon on le prend tel quel (anormal)
            montant = abs(solde_total) if solde_total < 0 else solde_total

        passif_data.append({
            'poste': regle.libelle,
            'radicaux': ', '.join(regle.prefixes),
            'montant': montant
        })

    # ÉTAPE 3: Ajouter le résultat net comme ligne du passif
    # Si Résultat Net > 0 (Bénéfice) → PASSIF
    # Si Résultat Net < 0 (Perte) → ACTIF (ligne négative au passif)
    passif_data.append({
        'poste': 'RESULTAT NET',
        'radicaux': '',
        'montant': resultat_net
    })

    # ÉTAPE 4: Calculer les totaux (incluant le résultat net déjà ajouté)
    total_actif = sum(item['montant'] for item in actif_data)
    total_passif = sum(item['montant'] for item in passif_data)

    # ÉTAPE 5: Vérification de l'équilibre (Total Actif DOIT = Total Passif)
    ecart = abs(total_actif - total_passif)
    logger.info(f"Bilan - Actif: {total_actif:,.2f} | Passif: {total_passif:,.2f} | RN: {resultat_net:,.2f} | Écart: {ecart:,.2f}")

    if ecart > 100:  # Tolérance de 100 FCFA
        logger.warning(f"⚠️  ATTENTION: Écart important Actif/Passif: {ecart:,.2f} FCFA")

    return {
        'actif': actif_data,
        'passif': passif_data,
        'total_actif': total_actif,
        'total_passif': total_passif,
        'resultat_net': resultat_net,
        'ecart': ecart
    }


def generate_cr_synthetique(
    balance: pd.DataFrame
) -> Dict:
    """
    Génère le compte de résultat synthétique en utilisant les règles de correspondance pré-compilées

    Args:
        balance: DataFrame de la balance générale

    Returns:
        Dictionnaire structuré avec CHARGES et PRODUITS
    """
    logger.info("Génération du CR synthétique depuis les règles pré-compilées")

    charges_data = []
    produits_data = []

    # Traiter les CHARGES
    for regle in get_cr_charges_regles():
        # Trouver les comptes correspondants
        comptes_matched = match_accounts_by_radicals(
            balance,
            regle.prefixes,
            regle.exclusions,
            regle.condition_solde
        )

        # Calculer le montant (pour les charges: total débit - total crédit = solde débiteur net)
        # Cela gère les cas où il y a des régularisations en crédit
        montant = comptes_matched['total_debit'].sum() - comptes_matched['total_credit'].sum()

        charges_data.append({
            'poste': regle.libelle,
            'radicaux': ', '.join(regle.prefixes),
            'montant': montant
        })

    # Traiter les PRODUITS
    for regle in get_cr_produits_regles():
        # Trouver les comptes correspondants
        comptes_matched = match_accounts_by_radicals(
            balance,
            regle.prefixes,
            regle.exclusions,
            regle.condition_solde
        )

        # Calculer le montant (pour les produits: total crédit - total débit = solde créditeur net)
        # Cela gère les cas où il y a des régularisations en débit
        montant = comptes_matched['total_credit'].sum() - comptes_matched['total_debit'].sum()

        produits_data.append({
            'poste': regle.libelle,
            'radicaux': ', '.join(regle.prefixes),
            'montant': montant
        })

    # Calculer les totaux
    total_charges = sum(item['montant'] for item in charges_data)
    total_produits = sum(item['montant'] for item in produits_data)
    resultat = total_produits - total_charges

    logger.info(f"CR synthétique généré - Charges: {total_charges:,.2f} | Produits: {total_produits:,.2f} | Résultat: {resultat:,.2f}")

    return {
        'charges': charges_data,
        'produits': produits_data,
        'total_charges': total_charges,
        'total_produits': total_produits,
        'resultat': resultat
    }
