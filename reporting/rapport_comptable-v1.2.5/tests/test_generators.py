#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Tests unitaires pour les modules de génération (Excel et PowerPoint)
"""

import pytest
import pandas as pd
from pathlib import Path
import sys
import tempfile

sys.path.insert(0, str(Path(__file__).parent.parent))

from modules.excel_generator import create_workbook, save_workbook
from modules.ppt_generator import create_basic_presentation, save_presentation
from utils.exceptions import ExcelGenerationError, PowerPointGenerationError


class TestExcelGenerator:
    """Tests pour le générateur Excel"""

    @pytest.fixture
    def sample_data(self):
        """Fixture pour créer des données de test"""
        df_gl = pd.DataFrame({
            'compte': [10000000, 20000000],
            'date': [pd.Timestamp('2025-01-01')] * 2,
            'journal': ['BQE'] * 2,
            'piece': ['001', '002'],
            'libelle': ['Test1', 'Test2'],
            'lettrage': ['', ''],
            'debit': [1000, 0],
            'credit': [0, 500],
            'solde': [1000, -500]
        })

        df_balance = pd.DataFrame({
            'compte': [10000000, 20000000],
            'libelle': ['Test1', 'Test2'],
            'total_debit': [1000, 0],
            'total_credit': [0, 500],
            'solde': [1000, -500],
            'solde_debiteur': [1000, 0],
            'solde_crediteur': [0, 500]
        })

        bilan = {
            'actif': df_balance[df_balance['solde_debiteur'] > 0],
            'passif': df_balance[df_balance['solde_crediteur'] > 0],
            'total_actif': 1000,
            'total_passif': 500
        }

        cr = {
            'charges': pd.DataFrame(),
            'produits': pd.DataFrame(),
            'total_charges': 0,
            'total_produits': 0,
            'resultat': 0
        }

        sig = {
            'chiffre_affaires': 0,
            'marge_commerciale': 0,
            'valeur_ajoutee': 0,
            'ebe': 0,
            'resultat_exploitation': 0,
            'resultat_net': 0
        }

        return df_gl, df_balance, bilan, cr, sig

    def test_create_workbook(self, sample_data):
        """Test de création du classeur Excel"""
        df_gl, df_balance, bilan, cr, sig = sample_data

        wb = create_workbook(df_gl, df_balance, bilan, cr, sig)

        assert wb is not None
        assert len(wb.sheetnames) == 6  # 6 feuilles attendues

        expected_sheets = ['GL BI SEP', 'BG BI SEP', 'BILAN SYNTH', 'CR SYNTH', 'SIG', 'SUIVI ACTIVITE']
        for sheet in expected_sheets:
            assert sheet in wb.sheetnames

    def test_save_workbook(self, sample_data):
        """Test de sauvegarde du classeur"""
        df_gl, df_balance, bilan, cr, sig = sample_data

        wb = create_workbook(df_gl, df_balance, bilan, cr, sig)

        # Utiliser un fichier temporaire
        with tempfile.NamedTemporaryFile(suffix='.xlsx', delete=False) as tmp:
            temp_path = tmp.name

        try:
            save_workbook(wb, temp_path)
            assert Path(temp_path).exists()
            assert Path(temp_path).stat().st_size > 0
        finally:
            # Nettoyer le fichier temporaire
            if Path(temp_path).exists():
                Path(temp_path).unlink()


class TestPowerPointGenerator:
    """Tests pour le générateur PowerPoint"""

    def test_create_basic_presentation(self):
        """Test de création d'une présentation de base"""
        prs = create_basic_presentation()

        assert prs is not None
        assert len(prs.slides) >= 5  # Au moins 5 slides

    def test_save_presentation(self):
        """Test de sauvegarde de la présentation"""
        prs = create_basic_presentation()

        # Utiliser un fichier temporaire
        with tempfile.NamedTemporaryFile(suffix='.pptx', delete=False) as tmp:
            temp_path = tmp.name

        try:
            save_presentation(prs, temp_path)
            assert Path(temp_path).exists()
            assert Path(temp_path).stat().st_size > 0
        finally:
            # Nettoyer le fichier temporaire
            if Path(temp_path).exists():
                Path(temp_path).unlink()


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
