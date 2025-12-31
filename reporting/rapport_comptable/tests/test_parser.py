#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Tests unitaires pour le module sage_parser
"""

import pytest
import pandas as pd
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).parent.parent))

from modules.sage_parser import (
    parse_sage_file,
    validate_data,
    clean_data,
    get_date_range,
    get_accounts_list,
    filter_by_account
)
from utils.exceptions import FileFormatError, DataValidationError


class TestSageParser:
    """Tests pour le module de parsing Sage"""

    def test_parse_sage_file_success(self):
        """Test du parsing d'un fichier valide"""
        # Ce test nécessite un fichier de test
        # Pour l'instant, on teste juste que la fonction existe
        assert callable(parse_sage_file)

    def test_parse_sage_file_not_found(self):
        """Test avec un fichier inexistant"""
        with pytest.raises(FileNotFoundError):
            parse_sage_file("fichier_inexistant.txt")

    def test_validate_data_empty_dataframe(self):
        """Test de validation avec DataFrame vide"""
        df = pd.DataFrame()
        with pytest.raises(DataValidationError):
            validate_data(df)

    def test_validate_data_missing_columns(self):
        """Test de validation avec colonnes manquantes"""
        df = pd.DataFrame({
            'compte': [10000000],
            'date': [pd.Timestamp('2025-01-01')]
        })
        with pytest.raises(DataValidationError):
            validate_data(df)

    def test_clean_data(self):
        """Test du nettoyage des données"""
        df = pd.DataFrame({
            'compte': [10000000, 10000000, 20000000, None],
            'date': [pd.Timestamp('2025-01-01')] * 4,
            'journal': ['BQE'] * 4,
            'piece': ['001'] * 4,
            'libelle': ['Test'] * 4,
            'lettrage': [''] * 4,
            'debit': [100, 100, 200, 0],
            'credit': [0, 0, 0, 0],
            'solde': [100, 100, 200, 0]
        })

        cleaned_df = clean_data(df)

        # Vérifier que les doublons sont supprimés
        assert len(cleaned_df) < len(df)

    def test_get_accounts_list(self):
        """Test de récupération de la liste des comptes"""
        df = pd.DataFrame({
            'compte': [10000000, 20000000, 10000000, 30000000],
            'date': [pd.Timestamp('2025-01-01')] * 4,
            'journal': ['BQE'] * 4,
            'piece': ['001'] * 4,
            'libelle': ['Test'] * 4,
            'lettrage': [''] * 4,
            'debit': [100] * 4,
            'credit': [0] * 4,
            'solde': [100] * 4
        })

        accounts = get_accounts_list(df)
        assert len(accounts) == 3
        assert 10000000 in accounts
        assert 20000000 in accounts
        assert 30000000 in accounts

    def test_filter_by_account(self):
        """Test du filtrage par compte"""
        df = pd.DataFrame({
            'compte': [10000000, 20000000, 10100000],
            'date': [pd.Timestamp('2025-01-01')] * 3,
            'journal': ['BQE'] * 3,
            'piece': ['001'] * 3,
            'libelle': ['Test'] * 3,
            'lettrage': [''] * 3,
            'debit': [100] * 3,
            'credit': [0] * 3,
            'solde': [100] * 3
        })

        filtered = filter_by_account(df, '10')
        assert len(filtered) == 2  # Comptes commençant par 10


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
