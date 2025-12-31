#!/bin/bash
# Script de lancement pour Linux/macOS
# Automatisation de rapports comptables

echo "========================================"
echo "Système d'automatisation de rapports"
echo "2BN CONSULTING"
echo "========================================"
echo ""

# Vérifier si Python est installé
if ! command -v python3 &> /dev/null; then
    echo "ERREUR: Python 3 n'est pas installé"
    echo "Veuillez installer Python 3.8 ou supérieur"
    exit 1
fi

# Afficher la version de Python
echo "Version Python: $(python3 --version)"

# Vérifier si les dépendances sont installées
echo "Vérification des dépendances..."
if ! python3 -c "import pandas, openpyxl, pptx" 2>/dev/null; then
    echo "Installation des dépendances..."
    pip3 install -r requirements.txt
fi

echo ""
echo "Lancement de l'application..."
echo ""

# Lancer le programme
python3 main.py

echo ""
echo "Fin de l'exécution"
