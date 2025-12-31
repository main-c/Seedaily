@echo off
REM Script de lancement pour Windows
REM Automatisation de rapports comptables

echo ========================================
echo Systeme d'automatisation de rapports
echo 2BN CONSULTING
echo ========================================
echo.

REM Vérifier si Python est installé
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERREUR: Python n'est pas installe ou n'est pas dans le PATH
    echo Veuillez installer Python 3.8 ou superieur
    pause
    exit /b 1
)

REM Vérifier si les dépendances sont installées
echo Verification des dependances...
python -c "import pandas, openpyxl, pptx" >nul 2>&1
if %errorlevel% neq 0 (
    echo Installation des dependances...
    pip install -r requirements.txt
    pip install pyinstaller
)

echo.
echo Lancement de l'application...
echo.

REM Lancer le programme
pyinstaller build_windows.spec

echo.
echo Appuyez sur une touche pour fermer...
pause >nul
