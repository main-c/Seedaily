#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Module de parsing du fichier Grand Livre exporté depuis Sage

Ce module gère:
- La lecture du fichier TXT avec encodage ISO-8859-1
- Le parsing des colonnes délimitées par tabulations
- La validation et le nettoyage des données
- La conversion en DataFrame Pandas structuré
"""

import pandas as pd
import logging
from pathlib import Path
from datetime import datetime
from typing import Optional

from utils.exceptions import ParsingError, FileFormatError, EncodingError, DataValidationError

logger = logging.getLogger(__name__)


def parse_sage_file(file_path: str) -> pd.DataFrame:
    """
    Charge et parse le fichier TXT Sage complet

    Args:
        file_path: Chemin vers le fichier TXT Sage

    Returns:
        DataFrame avec les colonnes: compte, date, journal, piece, libelle, lettrage, debit, credit, solde

    Raises:
        FileNotFoundError: Si le fichier n'existe pas
        EncodingError: Si problème d'encodage
        FileFormatError: Si le format du fichier est incorrect
    """
    logger.info(f"Parsing du fichier Sage: {file_path}")

    # Vérifier l'existence du fichier
    if not Path(file_path).exists():
        raise FileNotFoundError(f"Le fichier n'existe pas: {file_path}")

    try:
        # Lire le fichier avec encodage ISO-8859-1
        # Note: Le fichier Sage n'a PAS de ligne d'en-tête, il commence directement avec les données
        df = pd.read_csv(
            file_path,
            sep='\t',
            encoding='ISO-8859-1',
            header=None,
            names=['compte', 'date', 'journal', 'piece', 'libelle', 'lettrage', 'debit', 'credit', 'solde']
        )

        logger.info(f"Fichier lu avec succès: {len(df)} lignes")

        # Conversion des types de données
        df = _convert_data_types(df)

        logger.info("Types de données convertis avec succès")

        return df

    except UnicodeDecodeError as e:
        logger.error(f"Erreur d'encodage: {e}")
        raise EncodingError(f"Erreur d'encodage du fichier. Assurez-vous qu'il est en ISO-8859-1: {e}")

    except Exception as e:
        logger.error(f"Erreur lors du parsing: {e}")
        raise FileFormatError(f"Format de fichier incorrect: {e}")


def _convert_data_types(df: pd.DataFrame) -> pd.DataFrame:
    """
    Convertit les types de données des colonnes

    Args:
        df: DataFrame brut

    Returns:
        DataFrame avec types corrects
    """
    # Convertir le compte en entier
    df['compte'] = pd.to_numeric(df['compte'], errors='coerce').astype('Int64')

    # Convertir la date (format DDMMYY)
    df['date'] = pd.to_datetime(df['date'], format='%d%m%y', errors='coerce')

    # Convertir journal et piece en string
    df['journal'] = df['journal'].astype(str).str.strip()
    df['piece'] = df['piece'].astype(str).str.strip()
    df['libelle'] = df['libelle'].astype(str).str.strip()

    # Lettrage optionnel (nullable string)
    df['lettrage'] = df['lettrage'].fillna('').astype(str).str.strip()

    # Convertir débit, crédit et solde en float
    df['debit'] = pd.to_numeric(df['debit'], errors='coerce')
    df['credit'] = pd.to_numeric(df['credit'], errors='coerce')
    df['solde'] = pd.to_numeric(df['solde'], errors='coerce')

    # Remplacer NaN par 0 pour débit et crédit
    df['debit'] = df['debit'].fillna(0)
    df['credit'] = df['credit'].fillna(0)

    return df


def validate_data(df: pd.DataFrame) -> bool:
    """
    Vérifie la cohérence des données (comptes valides, dates correctes, soldes)

    Args:
        df: DataFrame à valider

    Returns:
        True si les données sont valides

    Raises:
        DataValidationError: Si les données sont invalides
    """
    logger.info("Validation des données")

    # Vérifier que le DataFrame n'est pas vide
    if df.empty:
        raise DataValidationError("Le fichier est vide")

    # Vérifier les colonnes requises
    required_columns = ['compte', 'date', 'journal', 'piece', 'libelle']
    missing_columns = [col for col in required_columns if col not in df.columns]

    if missing_columns:
        raise DataValidationError(f"Colonnes manquantes: {', '.join(missing_columns)}")

    # Vérifier les comptes (doivent être des entiers de 8 chiffres)
    invalid_accounts = df[df['compte'].isna() | (df['compte'] < 10000000) | (df['compte'] > 99999999)]

    if not invalid_accounts.empty:
        logger.warning(f"{len(invalid_accounts)} comptes invalides trouvés")
        # On ne lève pas d'erreur, on log seulement

    # Vérifier les dates
    invalid_dates = df[df['date'].isna()]

    if not invalid_dates.empty:
        logger.warning(f"{len(invalid_dates)} dates invalides trouvées")

    # Vérifier la cohérence des soldes (optionnel - peut être désactivé)
    # On vérifie simplement que les soldes existent
    if df['solde'].isna().all():
        raise DataValidationError("Aucun solde trouvé dans les données")

    logger.info("Validation réussie")
    return True


def clean_data(df: pd.DataFrame) -> pd.DataFrame:
    """
    Nettoie les données (gestion valeurs manquantes uniquement)

    IMPORTANT: Ne supprime PAS les doublons car en comptabilité,
    des écritures identiques peuvent être légitimes (ex: plusieurs
    paiements du même montant le même jour)

    IMPORTANT: Ne supprime PAS les lignes avec dates manquantes car
    certaines écritures comptables peuvent avoir des dates vides mais
    restent valides (ex: écritures d'ouverture, totaux, régularisations)

    Args:
        df: DataFrame à nettoyer

    Returns:
        DataFrame nettoyé
    """
    logger.info("Nettoyage des données")

    initial_rows = len(df)

    # Supprimer les lignes complètement vides
    df = df.dropna(how='all')

    # NE PAS supprimer les doublons - dangereux en comptabilité !
    # Les écritures identiques peuvent être légitimes
    # df = df.drop_duplicates()  # DÉSACTIVÉ

    # Supprimer uniquement les lignes avec compte manquant
    # (le compte est indispensable pour toute écriture comptable)
    # Les dates manquantes sont tolérées car certaines écritures valides n'ont pas de date
    df = df.dropna(subset=['compte'])

    # Trier par compte et date pour faciliter l'analyse
    # Les dates NaT seront placées à la fin lors du tri
    df = df.sort_values(['compte', 'date']).reset_index(drop=True)

    rows_removed = initial_rows - len(df)

    if rows_removed > 0:
        logger.info(f"{rows_removed} lignes supprimées lors du nettoyage (lignes vides ou incomplètes)")
    else:
        logger.info("Aucune ligne supprimée - toutes les données sont valides")

    logger.info(f"Données nettoyées: {len(df)} lignes conservées")

    return df


def get_date_range(df: pd.DataFrame) -> tuple:
    """
    Retourne la plage de dates des écritures

    Args:
        df: DataFrame des écritures

    Returns:
        Tuple (date_min, date_max)
    """
    date_min = df['date'].min()
    date_max = df['date'].max()

    return (date_min, date_max)


def get_accounts_list(df: pd.DataFrame) -> list:
    """
    Retourne la liste des comptes uniques

    Args:
        df: DataFrame des écritures

    Returns:
        Liste des comptes triée
    """
    return sorted(df['compte'].unique().tolist())


def filter_by_account(df: pd.DataFrame, account_prefix: str) -> pd.DataFrame:
    """
    Filtre les écritures par préfixe de compte

    Args:
        df: DataFrame des écritures
        account_prefix: Préfixe du compte (ex: "70" pour tous les comptes de produits)

    Returns:
        DataFrame filtré
    """
    account_str = str(account_prefix)
    filtered = df[df['compte'].astype(str).str.startswith(account_str)]

    logger.debug(f"Filtre compte {account_prefix}: {len(filtered)} lignes")

    return filtered


def filter_by_date_range(df: pd.DataFrame, start_date: datetime, end_date: datetime) -> pd.DataFrame:
    """
    Filtre les écritures par plage de dates

    Args:
        df: DataFrame des écritures
        start_date: Date de début
        end_date: Date de fin

    Returns:
        DataFrame filtré
    """
    filtered = df[(df['date'] >= start_date) & (df['date'] <= end_date)]

    logger.debug(f"Filtre dates {start_date} - {end_date}: {len(filtered)} lignes")

    return filtered
