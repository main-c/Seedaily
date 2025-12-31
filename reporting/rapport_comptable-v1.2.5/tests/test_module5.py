#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Test du Module 5: Génération PowerPoint
"""

import sys
import logging
from pathlib import Path

# Ajouter le répertoire parent au path
sys.path.insert(0, str(Path(__file__).parent.parent))

from modules.ppt_generator import generate_powerpoint
from modules.ui_interface import load_comments_from_file

# Configuration du logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)


def main():
    """Test de génération PowerPoint"""

    print("=" * 80)
    print("TEST MODULE 5 - GÉNÉRATION POWERPOINT")
    print("=" * 80)
    print()

    # Fichiers
    excel_file = "TEST_SUIVI_ACTIVITE_20251018_175622.xlsx"
    output_file = "TEST_RAPPORT_POWERPOINT.pptx"

    # Commentaires par défaut (si pas de fichier JSON)
    commentaires_default = {
        'periode': 'Septembre 2025',
        'cabinet': '2BN CONSULTING',
        'client': 'BAMBOO IMMO',
        'bilan': {
            'titre': 'ANALYSE DU BILAN',
            'commentaire': 'Le bilan présente une situation financière saine avec un actif total en progression.'
        },
        'compte_resultat': {
            'titre': 'ANALYSE DU COMPTE DE RÉSULTAT',
            'commentaire': 'Le résultat d\'exploitation montre une performance positive avec un chiffre d\'affaires en croissance.'
        },
        'sig': {
            'titre': 'SOLDES INTERMÉDIAIRES DE GESTION',
            'commentaire': 'Les indicateurs de gestion sont satisfaisants et en amélioration par rapport à la période précédente.'
        },
        'suivi_activite': {
            'titre': 'SUIVI D\'ACTIVITÉ MENSUEL',
            'commentaire': 'L\'activité mensuelle montre une tendance positive avec des variations saisonnières normales.'
        },
        'synthese': {
            'titre': 'SYNTHÈSE ET RECOMMANDATIONS',
            'commentaire': 'La société affiche de bons résultats. Recommandations: maintenir la dynamique commerciale.'
        }
    }

    try:
        # Vérifier que le fichier Excel existe
        if not Path(excel_file).exists():
            print(f"❌ Erreur: Fichier Excel non trouvé: {excel_file}")
            print(f"   Veuillez d'abord générer le fichier Excel avec test_module3.py")
            return

        print(f"📁 Fichier Excel source: {excel_file}")
        print(f"📄 Fichier PowerPoint cible: {output_file}")
        print()

        # Générer le PowerPoint
        print("🔄 Génération du PowerPoint...")
        generate_powerpoint(
            excel_path=excel_file,
            output_path=output_file,
            commentaires=commentaires_default
        )

        print()
        print("=" * 80)
        print("✅ TEST MODULE 5 TERMINÉ AVEC SUCCÈS!")
        print("=" * 80)
        print()
        print(f"📊 Rapport PowerPoint généré: {output_file}")
        print(f"📂 Emplacement: {Path(output_file).absolute()}")
        print()
        print("💡 Pour ouvrir le fichier:")
        print(f'   libreoffice "{Path(output_file).absolute()}"')
        print()

    except Exception as e:
        print()
        print("=" * 80)
        print("❌ ERREUR LORS DU TEST")
        print("=" * 80)
        print(f"Erreur: {e}")
        logger.error(f"Erreur lors du test: {e}", exc_info=True)


if __name__ == "__main__":
    main()
