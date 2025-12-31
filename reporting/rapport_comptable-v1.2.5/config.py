#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Configuration des règles de correspondance comptables (SYSCOHADA)

Les règles de correspondance entre les comptes et les postes du bilan/compte de résultat
sont définies selon le référentiel SYSCOHADA et sont STATIQUES.

Au lieu de parser un fichier Excel à chaque exécution, on pré-compile les règles
sous forme de mappings directs pour des performances optimales.
"""

from dataclasses import dataclass
from typing import Dict, List, Callable, Optional
from enum import Enum
import logging

logger = logging.getLogger(__name__)


class BilanSection(Enum):
    """Sections du bilan"""
    ACTIF = "ACTIF"
    PASSIF = "PASSIF"


class CRSection(Enum):
    """Sections du compte de résultat"""
    CHARGES = "CHARGES"
    PRODUITS = "PRODUITS"


@dataclass
class RegleCorrespondance:
    """
    Règle de correspondance optimisée pour un matching rapide

    Attributes:
        libelle: Libellé du poste comptable
        prefixes: Liste des préfixes de comptes à matcher (ex: ["101", "102", "103", "104"])
        exclusions: Liste des préfixes à exclure (ex: ["409"] pour "40(SAUF 409)")
        condition_solde: Condition sur le solde ("POSITIF", "NEGATIF", ou None)
        section: Section du document
    """
    libelle: str
    prefixes: List[str]
    exclusions: List[str]
    condition_solde: Optional[str]  # "POSITIF", "NEGATIF", ou None
    section: str


# ===========================
# RÈGLES DE CORRESPONDANCE DU BILAN (pré-compilées)
# ===========================

BILAN_ACTIF_REGLES = [
    RegleCorrespondance("IMMOBILISATIONS INCORPORELLES", ["21"], [], None, BilanSection.ACTIF.value),
    RegleCorrespondance("AMORTISSEMENT DES IMMOBILISATIONS INCORPORELLES", ["281", "291"], [], None, BilanSection.ACTIF.value),
    RegleCorrespondance("IMMOBILISATIONS CORPORELLES VALEURS BRUTES", ["22", "23", "24", "25"], [], None, BilanSection.ACTIF.value),
    RegleCorrespondance("AMORTISSEMENT DES IMMOBILISATIONS CORPORELLES", ["282", "283", "284", "291", "292", "293", "294", "295"], [], None, BilanSection.ACTIF.value),
    RegleCorrespondance("IMMOBILISATIONS FINANCIERES", ["26", "27"], [], None, BilanSection.ACTIF.value),
    RegleCorrespondance("STOCK", ["31", "32", "33", "34", "35", "36", "37", "38"], [], None, BilanSection.ACTIF.value),
    RegleCorrespondance("DEPRECIATION DES STOCKS", ["39"], [], None, BilanSection.ACTIF.value),
    RegleCorrespondance("FOURNISSEUR AVANCE VERSE", ["409"], [], None, BilanSection.ACTIF.value),
    # Compte 40 (sauf 409) avec SOLDE POSITIF = Avances/Trop-perçus fournisseurs = CRÉANCE
    RegleCorrespondance("FOURNISSEURS DEBITEURS", ["40"], ["409"], "POSITIF", BilanSection.ACTIF.value),
    RegleCorrespondance("CREANCES CLIENTS", ["41"], ["419"], None, BilanSection.ACTIF.value),
    RegleCorrespondance("AUTRES CREANCES", ["42", "43", "44", "45", "46", "185"], ["478"], "POSITIF", BilanSection.ACTIF.value),
    RegleCorrespondance("DEBITEURS DIVERS", ["4711"], [], None, BilanSection.ACTIF.value),
    RegleCorrespondance("BANQUES", ["52"], [], "POSITIF", BilanSection.ACTIF.value),
    RegleCorrespondance("CHEQUE POSTAUX", ["53"], [], "POSITIF", BilanSection.ACTIF.value),
    RegleCorrespondance("MONNAIE ELECTRONIQUE", ["55"], [], "POSITIF", BilanSection.ACTIF.value),
    RegleCorrespondance("CAISSE", ["57"], [], "POSITIF", BilanSection.ACTIF.value),
    RegleCorrespondance("VIREMENT INTERNE", ["585"], [], "POSITIF", BilanSection.ACTIF.value),
]

BILAN_PASSIF_REGLES = [
    RegleCorrespondance("CAPITAL SOCIAL", ["101", "102", "103", "104"], [], None, BilanSection.PASSIF.value),
    RegleCorrespondance("RAN", ["121", "129"], [], None, BilanSection.PASSIF.value),
    # NOTE: RESULTAT NET est maintenant ajouté automatiquement par generate_bilan_synthetique()
    # RegleCorrespondance("RESULTAT NET", ["130", "139"], [], None, BilanSection.PASSIF.value),  # RETIRÉ - doublon
    RegleCorrespondance("DETTES FINANCIERES", ["16"], [], None, BilanSection.PASSIF.value),
    # Compte 40 (sauf 409) avec SOLDE NÉGATIF = Dettes fournisseurs normales
    RegleCorrespondance("FOURNISSEUR D'EXPLOITATION", ["40"], ["409"], "NEGATIF", BilanSection.PASSIF.value),
    RegleCorrespondance("CLIENT AVANCE RECU", ["419"], [], None, BilanSection.PASSIF.value),
    RegleCorrespondance("DETTES SOCIALES", ["42", "43"], [], None, BilanSection.PASSIF.value),
    RegleCorrespondance("DETTES FISCALES", ["44"], [], None, BilanSection.PASSIF.value),
    RegleCorrespondance("AUTRES DETTES", ["45", "46", "185"], ["479"], "NEGATIF", BilanSection.PASSIF.value),
    RegleCorrespondance("CREDITEURS DIVERS", ["4712"], [], None, BilanSection.PASSIF.value),
    RegleCorrespondance("FOURNISSEUR D'INVESTISSEMENT", ["48", "49"], [], None, BilanSection.PASSIF.value),
    RegleCorrespondance("DECOUVERTS", ["52", "53", "55", "56", "57"], [], "NEGATIF", BilanSection.PASSIF.value),
    RegleCorrespondance("VIREMENT INTERNE", ["585"], [], "NEGATIF", BilanSection.PASSIF.value),
]


# ===========================
# RÈGLES DE CORRESPONDANCE DU COMPTE DE RÉSULTAT (pré-compilées)
# ===========================

CR_CHARGES_REGLES = [
    RegleCorrespondance("Achats de marchandises, de matières & fournitures liées", ["601"], [], None, CRSection.CHARGES.value),
    RegleCorrespondance("Variation de stock de marchandises", ["6031"], [], None, CRSection.CHARGES.value),
    RegleCorrespondance("Autres achats", ["604", "605", "608"], [], None, CRSection.CHARGES.value),
    RegleCorrespondance("Transports", ["61"], [], None, CRSection.CHARGES.value),
    RegleCorrespondance("Services exterieurs", ["62", "63"], [], None, CRSection.CHARGES.value),
    RegleCorrespondance("Impots & taxes", ["64"], [], None, CRSection.CHARGES.value),
    RegleCorrespondance("Charges du personnel", ["66"], [], None, CRSection.CHARGES.value),
    RegleCorrespondance("Autres charges", ["65"], [], None, CRSection.CHARGES.value),
    RegleCorrespondance("Frais financiers", ["67"], [], None, CRSection.CHARGES.value),
    RegleCorrespondance("Dotations aux amortissements", ["68", "69"], [], None, CRSection.CHARGES.value),
    RegleCorrespondance("Valeur comptables des cessions d'immobilisations", ["81"], [], None, CRSection.CHARGES.value),
    RegleCorrespondance("Charges hors activité ordinaires", ["83"], [], None, CRSection.CHARGES.value),
    RegleCorrespondance("Dotations HAO", ["85"], [], None, CRSection.CHARGES.value),
    RegleCorrespondance("Participations des travailleurs", ["87"], [], None, CRSection.CHARGES.value),
    RegleCorrespondance("Impots sur les societes", ["89"], [], None, CRSection.CHARGES.value),
]

CR_PRODUITS_REGLES = [
    RegleCorrespondance("Ventes de marchandises", ["701"], [], None, CRSection.PRODUITS.value),
    RegleCorrespondance("Ventes de produits fabrique", ["702", "703", "704"], [], None, CRSection.PRODUITS.value),
    RegleCorrespondance("Travaux, service vendus", ["705", "706"], [], None, CRSection.PRODUITS.value),
    RegleCorrespondance("Produit accessoirs", ["707"], [], None, CRSection.PRODUITS.value),
    RegleCorrespondance("Subvention d'exploitation", ["71"], [], None, CRSection.PRODUITS.value),
    RegleCorrespondance("Produit immobilisé", ["72"], [], None, CRSection.PRODUITS.value),
    RegleCorrespondance("Production stocké", ["73"], [], None, CRSection.PRODUITS.value),
    RegleCorrespondance("Autres produits (Accessoires)", ["75"], [], None, CRSection.PRODUITS.value),
    RegleCorrespondance("Transfert de charges", ["78"], [], None, CRSection.PRODUITS.value),
    RegleCorrespondance("Reprise", ["79"], [], None, CRSection.PRODUITS.value),
    RegleCorrespondance("Produit des cessions d'immobilisations", ["82"], [], None, CRSection.PRODUITS.value),
    RegleCorrespondance("Produit hors activité ordinaires", ["84"], [], None, CRSection.PRODUITS.value),
    RegleCorrespondance("Reprise de charges", ["86"], [], None, CRSection.PRODUITS.value),
    RegleCorrespondance("Subventions d'equilibre", ["88"], [], None, CRSection.PRODUITS.value),
]


# ===========================
# FONCTIONS D'ACCÈS
# ===========================

def get_bilan_actif_regles() -> List[RegleCorrespondance]:
    """Retourne les règles de correspondance pour l'ACTIF du bilan"""
    return BILAN_ACTIF_REGLES


def get_bilan_passif_regles() -> List[RegleCorrespondance]:
    """Retourne les règles de correspondance pour le PASSIF du bilan"""
    return BILAN_PASSIF_REGLES


def get_cr_charges_regles() -> List[RegleCorrespondance]:
    """Retourne les règles de correspondance pour les CHARGES du compte de résultat"""
    return CR_CHARGES_REGLES


def get_cr_produits_regles() -> List[RegleCorrespondance]:
    """Retourne les règles de correspondance pour les PRODUITS du compte de résultat"""
    return CR_PRODUITS_REGLES


def get_all_bilan_regles() -> Dict[str, List[RegleCorrespondance]]:
    """Retourne toutes les règles du bilan regroupées par section"""
    return {
        "ACTIF": BILAN_ACTIF_REGLES,
        "PASSIF": BILAN_PASSIF_REGLES
    }


def get_all_cr_regles() -> Dict[str, List[RegleCorrespondance]]:
    """Retourne toutes les règles du compte de résultat regroupées par section"""
    return {
        "CHARGES": CR_CHARGES_REGLES,
        "PRODUITS": CR_PRODUITS_REGLES
    }
