#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Fonctions de validation

Contient les fonctions utilitaires de validation:
- Validation des numéros de compte
- Validation des dates
- Validation des montants
- Validation de la cohérence comptable
"""

import re
from datetime import datetime
from typing import Optional, Tuple
import pandas as pd


def validate_account_number(account: int) -> bool:
    """
    Valide un numéro de compte comptable

    Args:
        account: Numéro de compte (8 chiffres)

    Returns:
        True si valide, False sinon
    """
    if not isinstance(account, int):
        return False

    # Vérifier que c'est un nombre à 8 chiffres
    if account < 10000000 or account > 99999999:
        return False

    return True


def validate_date(date_str: str, format: str = '%d%m%y') -> Tuple[bool, Optional[datetime]]:
    """
    Valide une date

    Args:
        date_str: Date en string
        format: Format de la date

    Returns:
        Tuple (validité, objet datetime ou None)
    """
    try:
        date_obj = datetime.strptime(date_str, format)
        return True, date_obj
    except (ValueError, TypeError):
        return False, None


def validate_amount(amount: float) -> bool:
    """
    Valide un montant

    Args:
        amount: Montant à valider

    Returns:
        True si valide, False sinon
    """
    if not isinstance(amount, (int, float)):
        return False

    # Vérifier que ce n'est pas NaN
    if pd.isna(amount):
        return False

    # Vérifier que c'est positif ou nul
    if amount < 0:
        return False

    return True


def validate_balance_equilibrium(total_debit: float, total_credit: float, tolerance: float = 0.01) -> bool:
    """
    Valide l'équilibre de la balance (total débit = total crédit)

    Args:
        total_debit: Total des débits
        total_credit: Total des crédits
        tolerance: Tolérance d'écart (défaut: 0.01)

    Returns:
        True si équilibré, False sinon
    """
    difference = abs(total_debit - total_credit)
    return difference <= tolerance


def validate_journal_code(code: str) -> bool:
    """
    Valide un code journal

    Args:
        code: Code journal (BQE, OD, RAN, etc.)

    Returns:
        True si valide, False sinon
    """
    if not isinstance(code, str):
        return False

    # Codes journaux courants
    valid_codes = ['BQE', 'OD', 'RAN', 'COM', 'IMMO', 'VTE', 'ACH', 'BQ']

    # Vérifier si le code correspond à un pattern connu ou est dans la liste
    code = code.strip().upper()

    if code in valid_codes:
        return True

    # Vérifier si c'est un pattern de type BQE06001, OD08001, etc.
    if re.match(r'^[A-Z]{2,5}\d*$', code):
        return True

    return False


def validate_dataframe_structure(df: pd.DataFrame, required_columns: list) -> Tuple[bool, list]:
    """
    Valide la structure d'un DataFrame

    Args:
        df: DataFrame à valider
        required_columns: Liste des colonnes requises

    Returns:
        Tuple (validité, liste des colonnes manquantes)
    """
    missing_columns = [col for col in required_columns if col not in df.columns]

    if missing_columns:
        return False, missing_columns

    return True, []


def validate_account_class(account: int, expected_class: int) -> bool:
    """
    Valide qu'un compte appartient à une classe comptable

    Args:
        account: Numéro de compte
        expected_class: Classe attendue (1-8)

    Returns:
        True si le compte appartient à la classe, False sinon
    """
    if not validate_account_number(account):
        return False

    account_str = str(account)
    first_digit = int(account_str[0])

    return first_digit == expected_class


def validate_debit_credit_coherence(debit: float, credit: float) -> bool:
    """
    Valide la cohérence entre débit et crédit (un seul des deux doit être non nul)

    Args:
        debit: Montant au débit
        credit: Montant au crédit

    Returns:
        True si cohérent, False sinon
    """
    # Les deux peuvent être nuls (écriture d'équilibre)
    if debit == 0 and credit == 0:
        return True

    # Un seul doit être non nul
    if (debit > 0 and credit == 0) or (debit == 0 and credit > 0):
        return True

    # Si les deux sont non nuls, c'est généralement une erreur
    # (sauf cas spéciaux de contre-passation)
    return False


def check_solde_coherence(df: pd.DataFrame, account: int) -> bool:
    """
    Vérifie la cohérence du solde progressif pour un compte

    Args:
        df: DataFrame du Grand Livre
        account: Numéro de compte à vérifier

    Returns:
        True si cohérent, False sinon
    """
    # Filtrer les écritures du compte
    account_df = df[df['compte'] == account].copy()

    if account_df.empty:
        return True

    # Trier par date
    account_df = account_df.sort_values('date')

    # Calculer le solde progressif attendu
    solde_calcule = 0

    for idx, row in account_df.iterrows():
        solde_calcule += row['debit'] - row['credit']

        # Vérifier avec une petite tolérance pour les erreurs d'arrondi
        if abs(solde_calcule - row['solde']) > 0.01:
            return False

    return True


def get_account_class_name(classe: int) -> str:
    """
    Retourne le nom d'une classe comptable

    Args:
        classe: Numéro de classe (1-8)

    Returns:
        Nom de la classe
    """
    classes = {
        1: "Comptes de capitaux",
        2: "Comptes d'immobilisations",
        3: "Comptes de stocks",
        4: "Comptes de tiers",
        5: "Comptes financiers",
        6: "Comptes de charges",
        7: "Comptes de produits",
        8: "Comptes spéciaux"
    }

    return classes.get(classe, "Classe inconnue")


def sanitize_text(text: str, max_length: Optional[int] = None) -> str:
    """
    Nettoie et sanitize un texte

    Args:
        text: Texte à nettoyer
        max_length: Longueur maximale (optionnel)

    Returns:
        Texte nettoyé
    """
    if not isinstance(text, str):
        text = str(text)

    # Supprimer les espaces multiples
    text = re.sub(r'\s+', ' ', text)

    # Supprimer les caractères spéciaux dangereux
    text = text.strip()

    # Tronquer si nécessaire
    if max_length and len(text) > max_length:
        text = text[:max_length] + '...'

    return text
