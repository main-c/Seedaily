#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Exceptions personnalisées du système

Hiérarchie des exceptions:
RapportException (base)
├── ParsingError
│   ├── FileFormatError
│   └── EncodingError
├── DataValidationError
│   ├── InvalidAccountError
│   └── InvalidDateError
├── GenerationError
│   ├── ExcelGenerationError
│   └── PowerPointGenerationError
└── ConfigurationError
"""


class RapportException(Exception):
    """Exception de base pour toutes les erreurs du système"""
    pass


# ========== Erreurs de Parsing ==========

class ParsingError(RapportException):
    """Erreur lors du parsing du fichier Sage"""
    pass


class FileFormatError(ParsingError):
    """Format de fichier incorrect"""
    pass


class EncodingError(ParsingError):
    """Erreur d'encodage du fichier"""
    pass


# ========== Erreurs de Validation ==========

class DataValidationError(RapportException):
    """Erreur de validation des données"""
    pass


class InvalidAccountError(DataValidationError):
    """Numéro de compte invalide"""
    pass


class InvalidDateError(DataValidationError):
    """Date invalide"""
    pass


# ========== Erreurs de Génération ==========

class GenerationError(RapportException):
    """Erreur lors de la génération de fichiers"""
    pass


class ExcelGenerationError(GenerationError):
    """Erreur lors de la génération du fichier Excel"""
    pass


class PowerPointGenerationError(GenerationError):
    """Erreur lors de la génération du fichier PowerPoint"""
    pass


# ========== Erreurs de Configuration ==========

class ConfigurationError(RapportException):
    """Erreur de configuration"""
    pass
