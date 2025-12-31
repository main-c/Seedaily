@echo off
REM =========================================================================
REM Script de Packaging - Générateur de Rapports Comptables
REM Crée un package ZIP prêt à livrer au client
REM =========================================================================

setlocal enabledelayedexpansion

echo.
echo ========================================================================
echo   CREATION DU PACKAGE DE LIVRAISON
echo ========================================================================
echo.

REM Vérifier que l'exe existe
if not exist "dist\RapportComptable.exe" (
    echo [ERREUR] L'executable n'existe pas!
    echo.
    echo Executez d'abord: build_exe.bat
    pause
    exit /b 1
)

REM Demander la version
set /p version="Entrez le numero de version (ex: 1.0): "
if "%version%"=="" set version=1.0

echo.
echo Version: %version%
echo.

REM Créer le dossier de package
set package_name=RapportComptable_v%version%
set package_dir=releases\%package_name%

echo [1/5] Creation du dossier de package...
if exist "releases\%package_name%" rmdir /s /q "releases\%package_name%"
if not exist "releases" mkdir releases
mkdir "%package_dir%"
echo.

echo [2/5] Copie de l'executable...
copy "dist\RapportComptable.exe" "%package_dir%\" >nul
if errorlevel 1 (
    echo [ERREUR] Copie de l'exe echouee
    pause
    exit /b 1
)
echo    OK - RapportComptable.exe
echo.

echo [3/5] Copie de la documentation...
copy "GUIDE_UTILISATEUR.md" "%package_dir%\" >nul
copy "README_LIVRAISON.md" "%package_dir%\README.md" >nul
copy "exemple_commentaires.txt" "%package_dir%\" >nul
copy "LICENSE" "%package_dir%\" >nul 2>nul
echo    OK - Documentation copiee
echo.

echo [4/5] Creation du fichier VERSION.txt...
(
    echo Generateur de Rapports Comptables
    echo Version: %version%
    echo Date de build: %date% %time%
    echo.
    echo Contenu:
    echo - RapportComptable.exe : Executable principal
    echo - GUIDE_UTILISATEUR.md : Guide d'utilisation complet
    echo - README.md : Instructions de demarrage rapide
    echo - exemple_commentaires.txt : Exemple de fichier commentaires
    echo.
    echo Configuration systeme requise:
    echo - Windows 10 ou superieur
    echo - Microsoft Excel installe
    echo - 4 GB RAM minimum
    echo - 500 MB espace disque
) > "%package_dir%\VERSION.txt"
echo    OK - VERSION.txt cree
echo.

echo [5/5] Creation de l'archive ZIP...
REM Vérifier si PowerShell est disponible (Windows 10+)
powershell -command "Compress-Archive -Path '%package_dir%\*' -DestinationPath 'releases\%package_name%.zip' -Force"
if errorlevel 1 (
    echo [AVERTISSEMENT] Compression PowerShell echouee
    echo Utilisez 7-Zip ou WinRAR pour compresser manuellement le dossier: %package_dir%
) else (
    echo    OK - %package_name%.zip cree
)
echo.

echo ========================================================================
echo   PACKAGE CREE AVEC SUCCES!
echo ========================================================================
echo.
echo Package: releases\%package_name%.zip
echo Dossier: releases\%package_name%\
echo.

REM Afficher la taille du package
for %%A in (releases\%package_name%.zip) do (
    set size=%%~zA
    set /a sizeMB=!size! / 1048576
)
echo Taille du ZIP: !sizeMB! MB (approximatif)
echo.

REM Calculer le hash SHA256 pour verification
echo Calcul du hash SHA256...
certutil -hashfile "releases\%package_name%.zip" SHA256 > "%package_dir%\SHA256.txt"
for /f "skip=1 tokens=*" %%A in ('certutil -hashfile "releases\%package_name%.zip" SHA256') do (
    set hash=%%A
    goto :done_hash
)
:done_hash
echo Hash SHA256: %hash%
echo.
echo Le hash a ete sauvegarde dans: %package_dir%\SHA256.txt
echo.

echo ========================================================================
echo   CONTENU DU PACKAGE
echo ========================================================================
echo.
dir /b "%package_dir%"
echo.

echo ========================================================================
echo   VERIFICATION
echo ========================================================================
echo.
echo [ ] Testez l'executable sur une machine propre (sans Python)
echo [ ] Verifiez que l'interface s'ouvre correctement
echo [ ] Testez une generation complete de rapport
echo [ ] Lisez le GUIDE_UTILISATEUR.md pour verification
echo [ ] Verifiez que tous les fichiers sont presents
echo.

echo ========================================================================
echo   LIVRAISON AU CLIENT
echo ========================================================================
echo.
echo 1. Envoyez le fichier ZIP: releases\%package_name%.zip
echo 2. Communiquez le hash SHA256 pour verification: %hash%
echo 3. Fournissez les informations de support:
echo    - Email: support@votrecabinet.com (a personnaliser)
echo    - Tel: +33 X XX XX XX XX (a personnaliser)
echo.

REM Demander si on veut ouvrir le dossier releases
set /p open="Ouvrir le dossier releases? (O/N): "
if /i "%open%"=="O" (
    explorer releases
)

echo.
echo Appuyez sur une touche pour quitter...
pause >nul
