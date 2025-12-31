@echo off
REM =========================================================================
REM Script de Build - Générateur de Rapports Comptables
REM Crée un exécutable Windows standalone sans code source
REM =========================================================================

echo.
echo ========================================================================
echo   GENERATEUR DE RAPPORTS COMPTABLES - BUILD WINDOWS
echo ========================================================================
echo.

REM Vérifier que Python est installé
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Python n'est pas installé ou n'est pas dans le PATH
    echo.
    echo Téléchargez Python depuis: https://www.python.org/downloads/
    pause
    exit /b 1
)

echo [1/5] Python detecte...
python --version
echo.

REM Vérifier que pip est disponible
pip --version >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] pip n'est pas installé
    pause
    exit /b 1
)

echo [2/5] Installation de PyInstaller...
pip install pyinstaller
if errorlevel 1 (
    echo [ERREUR] Installation de PyInstaller echouee
    pause
    exit /b 1
)
echo.

echo [3/5] Installation des dependances...
pip install -r requirements.txt
if errorlevel 1 (
    echo [AVERTISSEMENT] Certaines dependances ont echoue
    echo Continuons quand meme...
)
echo.

echo [4/5] Nettoyage des builds precedents...
if exist build rmdir /s /q build
if exist dist rmdir /s /q dist
if exist __pycache__ rmdir /s /q __pycache__
echo.

echo [5/5] Build de l'executable avec PyInstaller...
echo Cela peut prendre 2-5 minutes...
echo.
pyinstaller build_windows.spec

if errorlevel 1 (
    echo.
    echo [ERREUR] Build echoue!
    echo.
    echo Verifiez le fichier de log: build\RapportComptable\warn-RapportComptable.txt
    pause
    exit /b 1
)

echo.
echo ========================================================================
echo   BUILD REUSSI!
echo ========================================================================
echo.
echo Executable cree: dist\RapportComptable.exe
echo.

REM Vérifier la taille du fichier
for %%A in (dist\RapportComptable.exe) do (
    set size=%%~zA
    set /a sizeMB=!size! / 1048576
)

echo Taille de l'executable: %sizeMB% MB (approximatif)
echo.

echo ========================================================================
echo   PROCHAINES ETAPES
echo ========================================================================
echo.
echo 1. Testez l'executable: dist\RapportComptable.exe
echo 2. Copiez l'exe vers le dossier de livraison
echo 3. Ajoutez la documentation:
echo    - GUIDE_UTILISATEUR.md
echo    - README.md
echo    - exemple_commentaires.txt
echo.
echo 4. Zippez le tout pour livraison au client
echo.

REM Demander si on veut ouvrir le dossier dist
set /p open="Ouvrir le dossier dist? (O/N): "
if /i "%open%"=="O" (
    explorer dist
)

echo.
echo Appuyez sur une touche pour quitter...
pause >nul
