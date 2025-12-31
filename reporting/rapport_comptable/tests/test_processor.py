#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Tests unitaires pour le module data_processor
"""

import pytest
import pandas as pd
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).parent.parent))

from modules.data_processor import (
    calculate_balance,
    generate_bilan,
    generate_compte_resultat,
    calculate_sig,
    get_top_comptes,
    get_comptes_by_class
)


class TestDataProcessor:
    """Tests pour le module de traitement des données"""

    @pytest.fixture
    def sample_grand_livre(self):
        """Fixture pour créer un Grand Livre de test"""
        return pd.DataFrame({
            'compte': [10000000, 10000000, 60000000, 70000000],
            'date': [pd.Timestamp('2025-01-01')] * 4,
            'journal': ['BQE'] * 4,
            'piece': ['001', '002', '003', '004'],
            'libelle': ['Test'] * 4,
            'lettrage': [''] * 4,
            'debit': [500000, 0, 100000, 0],
            'credit': [0, 200000, 0, 150000],
            'solde': [500000, 300000, 100000, -50000]
        })

    def test_calculate_balance(self, sample_grand_livre):
        """Test du calcul de la balance"""
        balance = calculate_balance(sample_grand_livre)

        assert len(balance) == 3  # 3 comptes uniques
        assert 'total_debit' in balance.columns
        assert 'total_credit' in balance.columns
        assert 'solde' in balance.columns

        # Vérifier le compte 10000000
        compte_10 = balance[balance['compte'] == 10000000].iloc[0]
        assert compte_10['total_debit'] == 500000
        assert compte_10['total_credit'] == 200000
        assert compte_10['solde'] == 300000

    def test_generate_bilan(self, sample_grand_livre):
        """Test de la génération du bilan"""
        balance = calculate_balance(sample_grand_livre)
        bilan = generate_bilan(balance)

        assert 'actif' in bilan
        assert 'passif' in bilan
        assert 'total_actif' in bilan
        assert 'total_passif' in bilan

        # Le compte 10000000 avec solde débiteur devrait être dans l'actif
        assert len(bilan['actif']) > 0

    def test_generate_compte_resultat(self, sample_grand_livre):
        """Test de la génération du compte de résultat"""
        balance = calculate_balance(sample_grand_livre)
        cr = generate_compte_resultat(balance)

        assert 'charges' in cr
        assert 'produits' in cr
        assert 'total_charges' in cr
        assert 'total_produits' in cr
        assert 'resultat' in cr

        # Vérifier les totaux
        assert cr['total_charges'] == 100000  # Compte 60000000
        assert cr['total_produits'] == 150000  # Compte 70000000
        assert cr['resultat'] == 50000  # Produits - Charges

    def test_calculate_sig(self, sample_grand_livre):
        """Test du calcul des SIG"""
        balance = calculate_balance(sample_grand_livre)
        cr = generate_compte_resultat(balance)
        sig = calculate_sig(cr)

        assert 'chiffre_affaires' in sig
        assert 'resultat_net' in sig
        assert 'ebe' in sig

        # Le résultat net doit correspondre au résultat du CR
        assert sig['resultat_net'] == cr['resultat']

    def test_get_top_comptes(self, sample_grand_livre):
        """Test de récupération des top comptes"""
        balance = calculate_balance(sample_grand_livre)
        top_comptes = get_top_comptes(balance, n=2, by='debit')

        assert len(top_comptes) <= 2
        # Le premier doit être le compte avec le plus de débit
        assert top_comptes.iloc[0]['total_debit'] >= top_comptes.iloc[1]['total_debit']

    def test_get_comptes_by_class(self, sample_grand_livre):
        """Test du filtrage par classe"""
        balance = calculate_balance(sample_grand_livre)

        # Classe 1 (comptes de capitaux)
        classe_1 = get_comptes_by_class(balance, 1)
        assert len(classe_1) == 1
        assert classe_1.iloc[0]['compte'] == 10000000

        # Classe 6 (charges)
        classe_6 = get_comptes_by_class(balance, 6)
        assert len(classe_6) == 1
        assert classe_6.iloc[0]['compte'] == 60000000

        # Classe 7 (produits)
        classe_7 = get_comptes_by_class(balance, 7)
        assert len(classe_7) == 1
        assert classe_7.iloc[0]['compte'] == 70000000


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
