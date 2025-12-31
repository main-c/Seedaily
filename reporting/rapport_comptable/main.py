#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Module 6: Orchestration - Script Principal

Ce script coordonne tous les modules pour générer automatiquement
le rapport comptable complet (Excel + PowerPoint).

Flux:
    1. Parser le fichier TXT Sage (Module 1)
    2. Traiter les données comptables (Module 2)
    3. Générer le fichier Excel (Module 3)
    4. Saisir les commentaires (Module 4 - optionnel)
    5. Générer le PowerPoint (Module 5)
"""

import sys
import argparse
import logging
from pathlib import Path
from datetime import datetime
from typing import Optional

# Ajouter le répertoire parent au path
sys.path.insert(0, str(Path(__file__).parent))

from modules import sage_parser
from modules import data_processor
from modules import excel_generator
from modules import ui_interface
from modules import ppt_generator
from modules import security
from modules.data_processor import get_client_code_from_name


def setup_logging(log_level: str = "INFO") -> logging.Logger:
    """Configure le système de logging"""
    
    # Créer le répertoire logs s'il n'existe pas
    log_dir = Path(__file__).parent / "logs"
    log_dir.mkdir(exist_ok=True)
    
    # Nom du fichier de log avec timestamp
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    log_file = log_dir / f"rapport_{timestamp}.log"
    
    # Configuration
    logging.basicConfig(
        level=getattr(logging, log_level.upper()),
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        handlers=[
            logging.FileHandler(log_file, encoding='utf-8'),
            logging.StreamHandler()
        ]
    )
    
    logger = logging.getLogger(__name__)
    logger.info(f"Fichier de log: {log_file}")
    
    return logger


def generer_rapport_complet(
    fichier_sage: Optional[str] = None,
    output_excel: Optional[str] = None,
    output_ppt: Optional[str] = None,
    commentaires_file: Optional[str] = None,
    client_name: Optional[str] = None,
    sans_ui: bool = False,
    logger: Optional[logging.Logger] = None
):
    """
    Génère le rapport comptable complet

    Args:
        fichier_sage: Chemin vers le fichier TXT exporté de Sage (optionnel si sélectionné via UI)
        output_excel: Chemin de sortie du fichier Excel (optionnel)
        output_ppt: Chemin de sortie du PowerPoint (optionnel)
        commentaires_file: Fichier JSON avec commentaires pré-saisis (optionnel)
        sans_ui: Si True, génère sans interface utilisateur
        logger: Logger (optionnel)
    """

    if logger is None:
        logger = logging.getLogger(__name__)

    try:
        print("=" * 80)
        print("           GÉNÉRATION AUTOMATIQUE DU RAPPORT COMPTABLE")
        print("=" * 80)
        print()

        # ====================================================================
        # ÉTAPE 0A: VÉRIFICATION DE SÉCURITÉ
        # ====================================================================
        authorized, username = security.security_check()

        if not authorized:
            logger.error("Vérification de sécurité échouée")
            return False

        logger.info(f"Utilisateur autorisé: {username}")

        # ====================================================================
        # ÉTAPE 0: COLLECTER LA CONFIGURATION (SI NÉCESSAIRE)
        # ====================================================================
        config = None
        commentaires = None
        generer_excel = True
        generer_ppt = True
        dossier_sortie = None

        # Si le fichier sage n'est pas fourni ou si on n'est pas en mode sans UI
        if not fichier_sage and not sans_ui:
            # Mode interface graphique: afficher la configuration
            print("🔄 Étape 0/6: Configuration - Saisie des paramètres...")
            logger.info("Lancement de l'interface de configuration")

            config = ui_interface.collect_configuration()

            if not config:
                print("   ⚠️  Configuration annulée par l'utilisateur")
                logger.warning("Configuration annulée par l'utilisateur")
                return False

            # Récupérer TOUTES les informations depuis la configuration
            fichier_sage = config.get('fichier_sage')
            dossier_sortie = config.get('dossier_sortie')
            generer_excel = config.get('generer_excel', True)
            generer_ppt = config.get('generer_ppt', True)

            print(f"   ✅ Configuration complétée")
            print()

        elif not fichier_sage:
            # Mode sans UI mais pas de fichier fourni
            raise ValueError("En mode sans UI, vous devez spécifier le fichier source en argument")
        else:
            # Mode sans UI ou fichier fourni en ligne de commande
            # Créer une config minimale avec le client si fourni
            if client_name:
                client_code = get_client_code_from_name(client_name)
                config = {
                    'client': client_name,
                    'client_code': client_code,
                    'periode': datetime.now().strftime("%B %Y"),
                    'cabinet': '2BN CONSULTING'
                }
                if client_code:
                    logger.info(f"Mode ligne de commande: client '{client_name}' -> code '{client_code}'")
                else:
                    logger.info(f"Mode ligne de commande: client '{client_name}' (mapping par défaut)")
            elif not config:
                # Pas de config du tout
                config = {}

        # Vérifier que le fichier source existe
        if not fichier_sage:
            raise ValueError("Aucun fichier source Sage n'a été spécifié")

        if not Path(fichier_sage).exists():
            raise FileNotFoundError(f"Fichier source introuvable: {fichier_sage}")

        # Générer les noms de fichiers de sortie si non fournis
        base_name = Path(fichier_sage).stem
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

        # Si un dossier de sortie est spécifié, l'utiliser
        if dossier_sortie:
            if output_excel is None:
                output_excel = str(Path(dossier_sortie) / f"RAPPORT_{base_name}_{timestamp}.xlsx")

            if output_ppt is None:
                output_ppt = str(Path(dossier_sortie) / f"RAPPORT_{base_name}_{timestamp}.pptx")
        else:
            if output_excel is None:
                output_excel = f"RAPPORT_{base_name}_{timestamp}.xlsx"

            if output_ppt is None:
                output_ppt = f"RAPPORT_{base_name}_{timestamp}.pptx"

        logger.info(f"Fichier source: {fichier_sage}")
        logger.info(f"Fichier Excel: {output_excel}")
        logger.info(f"Fichier PowerPoint: {output_ppt}")

        # ====================================================================
        # ÉTAPE 1: PARSER LE FICHIER SAGE
        # ====================================================================
        print("🔄 Étape 1/5: Parsing du fichier Sage...")
        logger.info("Étape 1: Parsing du fichier Sage")

        df = sage_parser.parse_sage_file(fichier_sage)
        df = sage_parser.clean_data(df)
        
        nb_ecritures = len(df)
        logger.info(f"✅ {nb_ecritures} écritures chargées")
        print(f"   ✅ {nb_ecritures} écritures chargées")
        print()
        
        # ====================================================================
        # ÉTAPE 2: TRAITER LES DONNÉES
        # ====================================================================
        print("🔄 Étape 2/5: Traitement des données comptables...")
        logger.info("Étape 2: Traitement des données")

        # Calculer la balance
        balance = data_processor.calculate_balance(df)
        logger.info(f"Balance calculée: {len(balance)} comptes")

        # Générer le compte de résultat (utilise les règles pré-compilées dans config.py)
        compte_resultat = data_processor.generate_cr_synthetique(balance)
        resultat_net = compte_resultat['resultat']
        logger.info(f"Résultat net: {resultat_net:,.2f} FCFA")

        # Générer le bilan (utilise les règles pré-compilées dans config.py)
        bilan = data_processor.generate_bilan_synthetique(balance, resultat_net)
        logger.info(f"Bilan généré - Actif: {bilan['total_actif']:,.2f}, Passif: {bilan['total_passif']:,.2f}")

        # Calculer les SIG
        sig = data_processor.calculate_sig(compte_resultat)
        logger.info(f"SIG calculés: {len(sig)} indicateurs")

        print(f"   ✅ Balance: {len(balance)} comptes")
        print(f"   ✅ Résultat net: {resultat_net:,.2f} FCFA")
        print()
        
        # ====================================================================
        # ÉTAPE 3: GÉNÉRER LE FICHIER EXCEL
        # ====================================================================
        if generer_excel:
            print("🔄 Étape 3/5: Génération du fichier Excel...")
            logger.info("Étape 3: Génération Excel")

            # Récupérer le code client depuis la configuration
            client_code = config.get('client_code') if config else None

            if client_code:
                logger.info(f"Génération Excel avec mapping client: {client_code}")
            else:
                logger.info("Génération Excel avec mapping par défaut")

            wb = excel_generator.create_workbook(
                df_grand_livre=df,
                df_balance=balance,
                bilan=bilan,
                compte_resultat=compte_resultat,
                sig=sig,
                client_code=client_code
            )

            # Ajouter le watermark à toutes les feuilles (nom du cabinet)
            logger.info("Ajout du watermark au fichier Excel...")
            cabinet_name = config.get('cabinet', '2BN CONSULTING') if config else '2BN CONSULTING'
            security.add_watermark_to_workbook(wb, cabinet_name)

            wb.save(output_excel)

            # Enregistrer la génération dans l'audit log
            security.log_report_generation(
                username=username,
                client_code=client_code or "INCONNU",
                gl_file=fichier_sage,
                output_excel=output_excel
            )

            print(f"   ✅ Fichier Excel généré: {output_excel}")
            logger.info(f"Fichier Excel généré: {output_excel}")
            print()
        else:
            print("⏭️  Étape 3/5: Génération Excel ignorée (option non cochée)")
            print()
        
        # ====================================================================
        # ÉTAPE 4: ENRICHIR LES COMMENTAIRES
        # ====================================================================
        if sans_ui:
            print("ℹ️  Étape 4/6: Mode automatique - commentaires par défaut")
            logger.info("Mode sans UI - commentaires par défaut")

            # Commentaires par défaut
            commentaires = {
                'periode': config.get('periode') if config else datetime.now().strftime("%B %Y"),
                'cabinet': config.get('cabinet') if config else '2BN CONSULTING',
                'client': config.get('client') if config else 'BAMBOO IMMO',
                'bilan': {'commentaire': 'Analyse du bilan générée automatiquement.'},
                'compte_resultat': {'commentaire': 'Analyse du compte de résultat générée automatiquement.'},
                'sig': {'commentaire': 'Analyse des SIG générée automatiquement.'},
                'suivi_activite': {'commentaire': 'Suivi mensuel généré automatiquement.'},
                'synthese': {'commentaire': 'Synthèse générée automatiquement.'}
            }

        elif commentaires_file and Path(commentaires_file).exists():
            print(f"🔄 Étape 4/6: Chargement des commentaires depuis {commentaires_file}...")
            logger.info(f"Chargement des commentaires: {commentaires_file}")

            commentaires = ui_interface.load_comments_from_file(commentaires_file)
            print(f"   ✅ Commentaires chargés")
            logger.info("Commentaires chargés avec succès")

        elif config:
            # Interface pour enrichir les commentaires des documents déjà générés
            print("🔄 Étape 4/6: Enrichissement des commentaires...")
            logger.info("Lancement de l'interface d'enrichissement")

            commentaires = ui_interface.collect_comments_for_existing_reports(
                periode=config.get('periode', ''),
                cabinet=config.get('cabinet', '2BN CONSULTING'),
                client=config.get('client', 'BAMBOO IMMO'),
                excel_path=output_excel if generer_excel else None,
                ppt_path=output_ppt if generer_ppt else None
            )

            if commentaires:
                print(f"   ✅ Commentaires enrichis")
                logger.info("Commentaires enrichis avec succès")
            else:
                print(f"   ⚠️  Commentaires non enrichis - utilisation des valeurs par défaut")
                logger.warning("Commentaires non enrichis")
                # Utiliser les infos de config sans commentaires détaillés
                commentaires = {
                    'periode': config.get('periode', ''),
                    'cabinet': config.get('cabinet', '2BN CONSULTING'),
                    'client': config.get('client', 'BAMBOO IMMO')
                }

        print()
        
        # ====================================================================
        # ÉTAPE 5: GÉNÉRER LE POWERPOINT INITIAL
        # ====================================================================
        if generer_ppt:
            print("🔄 Étape 5/6: Génération du PowerPoint initial...")
            logger.info("Étape 5: Génération PowerPoint initial")

            # Utiliser les infos de config pour la première génération
            initial_commentaires = {
                'periode': config.get('periode', '') if config else '',
                'cabinet': config.get('cabinet', '2BN CONSULTING') if config else '2BN CONSULTING',
                'client': config.get('client', 'BAMBOO IMMO') if config else 'BAMBOO IMMO',
            }

            ppt_generator.generate_powerpoint(
                excel_path=output_excel,
                output_path=output_ppt,
                commentaires=initial_commentaires
            )

            print(f"   ✅ Fichier PowerPoint initial généré: {output_ppt}")
            logger.info(f"Fichier PowerPoint initial généré: {output_ppt}")
            print()
        else:
            print("⏭️  Étape 5/6: Génération PowerPoint ignorée (option non cochée)")
            print()

        # ====================================================================
        # ÉTAPE 6: RÉGÉNÉRER LE POWERPOINT AVEC COMMENTAIRES ENRICHIS
        # ====================================================================
        if generer_ppt and commentaires and not sans_ui:
            print("🔄 Étape 6/6: Mise à jour du PowerPoint avec les commentaires...")
            logger.info("Étape 6: Régénération PowerPoint avec commentaires enrichis")

            ppt_generator.generate_powerpoint(
                excel_path=output_excel,
                output_path=output_ppt,
                commentaires=commentaires
            )

            print(f"   ✅ PowerPoint mis à jour avec les commentaires")
            logger.info(f"PowerPoint mis à jour avec commentaires: {output_ppt}")
            print()
        elif not generer_ppt:
            print("⏭️  Étape 6/6: Mise à jour PowerPoint ignorée (option non cochée)")
            print()
        else:
            print("ℹ️  Étape 6/6: Pas de mise à jour des commentaires")
            print()
        
        # ====================================================================
        # RÉSUMÉ FINAL
        # ====================================================================
        print("=" * 80)
        print("           ✅ RAPPORT COMPTABLE GÉNÉRÉ AVEC SUCCÈS!")
        print("=" * 80)
        print()
        print("📊 Fichiers générés:")
        if generer_excel:
            print(f"   📄 Excel:      {Path(output_excel).absolute()}")
        if generer_ppt:
            print(f"   📊 PowerPoint: {Path(output_ppt).absolute()}")
        print()
        print("📈 Statistiques:")
        print(f"   • Écritures traitées: {nb_ecritures}")
        print(f"   • Comptes dans la balance: {len(balance)}")
        print(f"   • Résultat net: {resultat_net:,.2f} FCFA")
        print()
        print("=" * 80)
        
        logger.info("Génération du rapport terminée avec succès")
        
        return True
        
    except Exception as e:
        print()
        print("=" * 80)
        print("           ❌ ERREUR LORS DE LA GÉNÉRATION DU RAPPORT")
        print("=" * 80)
        print(f"Erreur: {e}")
        print()
        logger.error(f"Erreur lors de la génération: {e}", exc_info=True)
        return False


def main():
    """Point d'entrée principal du script"""
    
    # Parser les arguments
    parser = argparse.ArgumentParser(
        description="Génération automatique de rapports comptables",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Exemples d'utilisation:

  # Mode interface graphique (recommandé pour les utilisateurs finaux)
  python main.py

  # Avec fichier source spécifié en ligne de commande
  python main.py fichier_sage.txt

  # Génération sans interface (mode automatique)
  python main.py fichier_sage.txt --sans-ui

  # Avec fichiers de sortie personnalisés
  python main.py fichier_sage.txt --excel rapport.xlsx --ppt rapport.pptx

  # Avec commentaires pré-saisis
  python main.py fichier_sage.txt --commentaires commentaires.txt

  # Avec client spécifique (utilise le mapping personnalisé)
  python main.py fichier_sage.txt --client "BLUE LEASE" --sans-ui
        """
    )
    
    parser.add_argument(
        'fichier_sage',
        nargs='?',  # Rendre l'argument optionnel
        help="Fichier TXT exporté de Sage (optionnel, peut être sélectionné via l'interface)"
    )
    
    parser.add_argument(
        '--excel', '-e',
        help="Nom du fichier Excel de sortie (optionnel)"
    )
    
    parser.add_argument(
        '--ppt', '-p',
        help="Nom du fichier PowerPoint de sortie (optionnel)"
    )
    
    parser.add_argument(
        '--commentaires', '-c',
        help="Fichier JSON avec commentaires pré-saisis (optionnel)"
    )

    parser.add_argument(
        '--client',
        help="Nom du client (ex: 'BLUE LEASE', 'BIT', etc.) pour utiliser son mapping spécifique"
    )

    parser.add_argument(
        '--sans-ui',
        action='store_true',
        help="Générer sans interface utilisateur (mode automatique)"
    )

    parser.add_argument(
        '--log-level',
        choices=['DEBUG', 'INFO', 'WARNING', 'ERROR'],
        default='INFO',
        help="Niveau de logging (défaut: INFO)"
    )
    
    args = parser.parse_args()
    
    # Configuration du logging
    logger = setup_logging(args.log_level)
    
    # Génération du rapport
    success = generer_rapport_complet(
        fichier_sage=args.fichier_sage,
        output_excel=args.excel,
        output_ppt=args.ppt,
        commentaires_file=args.commentaires,
        client_name=args.client,
        sans_ui=args.sans_ui,
        logger=logger
    )
    
    # Code de sortie
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
