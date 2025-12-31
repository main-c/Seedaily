# -*- mode: python ; coding: utf-8 -*-

"""
Fichier de spécification PyInstaller pour créer un exécutable Windows
du Générateur de Rapports Comptables

Usage sur Windows:
    pip install pyinstaller
    pyinstaller build_windows.spec

Le fichier .exe sera créé dans le dossier dist/
"""

import sys
from pathlib import Path

block_cipher = None

# Définir les données à inclure
datas = [
    ('config.json', '.'),
    ('README.md', '.'),
    ('LICENSE', '.'),
    ('exemple_commentaires.txt', '.'),
]

# Définir les modules cachés (importés dynamiquement)
hiddenimports = [
    'tkinter',
    'tkinter.filedialog',
    'tkinter.messagebox',
    'tkinter.scrolledtext',
    'openpyxl',
    'openpyxl.styles',
    'openpyxl.utils',
    'python-pptx',
    'pptx',
    'pptx.util',
    'pptx.enum.text',
    'pptx.dml.color',
    'PIL',
    'PIL.Image',
    'PIL.ImageDraw',
    'PIL.ImageFont',
    'PIL.ImageGrab',
    'win32com',
    'win32com.client',
    'pandas',
    'numpy',
]

a = Analysis(
    ['main.py'],
    pathex=[],
    binaries=[],
    datas=datas,
    hiddenimports=hiddenimports,
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=['matplotlib', 'scipy', 'pytest', 'IPython'],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(
    a.pure,
    a.zipped_data,
    cipher=block_cipher
)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='RapportComptable-v1.2.1',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=False,  # Pas de console (interface graphique uniquement)
    disable_windowed_traceback=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon=None,  # Ajoutez un fichier .ico ici si vous avez un logo
    version_file=None,
)
