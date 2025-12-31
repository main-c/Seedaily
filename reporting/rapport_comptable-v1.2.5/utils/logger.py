#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Configuration du système de logging

Gère:
- Configuration centralisée du logging
- Création de fichiers de logs
- Formatage des messages
- Niveaux de logging (DEBUG, INFO, WARNING, ERROR, CRITICAL)
"""

import logging
import sys
from pathlib import Path
from datetime import datetime


def setup_logger(name: str = 'rapport_comptable', level: str = 'INFO') -> logging.Logger:
    """
    Configure et retourne un logger

    Args:
        name: Nom du logger
        level: Niveau de logging (DEBUG, INFO, WARNING, ERROR, CRITICAL)

    Returns:
        Logger configuré
    """

    # Créer le répertoire de logs s'il n'existe pas
    log_dir = Path('logs')
    log_dir.mkdir(exist_ok=True)

    # Nom du fichier de log avec timestamp
    log_file = log_dir / f"rapport_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"
    error_log_file = log_dir / "rapport_errors.log"

    # Créer le logger
    logger = logging.getLogger(name)
    logger.setLevel(getattr(logging, level.upper()))

    # Éviter les doublons de handlers
    if logger.handlers:
        return logger

    # Format des messages
    formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )

    # Handler pour la console (stdout)
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(logging.INFO)
    console_handler.setFormatter(formatter)

    # Handler pour le fichier de log principal
    file_handler = logging.FileHandler(log_file, encoding='utf-8')
    file_handler.setLevel(logging.DEBUG)
    file_handler.setFormatter(formatter)

    # Handler pour le fichier d'erreurs uniquement
    error_handler = logging.FileHandler(error_log_file, encoding='utf-8')
    error_handler.setLevel(logging.ERROR)
    error_handler.setFormatter(formatter)

    # Ajouter les handlers au logger
    logger.addHandler(console_handler)
    logger.addHandler(file_handler)
    logger.addHandler(error_handler)

    # Log initial
    logger.info(f"Logger initialisé - Niveau: {level}")
    logger.info(f"Fichier de log: {log_file}")

    return logger


def get_logger(name: str) -> logging.Logger:
    """
    Récupère un logger existant

    Args:
        name: Nom du logger

    Returns:
        Logger
    """
    return logging.getLogger(name)


def set_log_level(logger: logging.Logger, level: str):
    """
    Modifie le niveau de logging

    Args:
        logger: Logger à modifier
        level: Nouveau niveau (DEBUG, INFO, WARNING, ERROR, CRITICAL)
    """
    logger.setLevel(getattr(logging, level.upper()))
    logger.info(f"Niveau de logging changé à {level}")


def log_exception(logger: logging.Logger, exception: Exception, message: str = ""):
    """
    Log une exception avec traceback complet

    Args:
        logger: Logger à utiliser
        exception: Exception à logger
        message: Message additionnel
    """
    if message:
        logger.error(f"{message}: {exception}", exc_info=True)
    else:
        logger.error(f"Exception: {exception}", exc_info=True)


def create_section_log(logger: logging.Logger, title: str, width: int = 80):
    """
    Crée une section visuelle dans les logs

    Args:
        logger: Logger à utiliser
        title: Titre de la section
        width: Largeur de la ligne de séparation
    """
    separator = "=" * width
    logger.info(separator)
    logger.info(title.center(width))
    logger.info(separator)
