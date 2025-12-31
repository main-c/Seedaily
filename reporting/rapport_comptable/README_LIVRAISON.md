# 📦 Package de Livraison - Générateur de Rapports Comptables

## 📋 Contenu du Package

Ce package contient tout le nécessaire pour utiliser le Générateur de Rapports Comptables sur Windows :

```
RapportComptable_v1.0/
├── 📄 RapportComptable.exe           ← Exécutable principal (double-cliquez)
├── 📖 GUIDE_UTILISATEUR.md           ← Guide d'utilisation complet
├── 📖 README.md                      ← Ce fichier
├── 📄 exemple_commentaires.txt       ← Exemple de fichier commentaires
└── 📄 LICENSE                        ← Licence d'utilisation
```

## 🚀 Installation et Utilisation

### Installation

**Aucune installation nécessaire !**

1. Décompressez le fichier ZIP dans un dossier de votre choix
2. Double-cliquez sur `RapportComptable.exe`
3. C'est tout !

### Première Utilisation

1. **Lancez l'application** : Double-clic sur `RapportComptable.exe`

2. **Sélectionnez votre fichier Sage** :
   - Cliquez sur "Parcourir" à côté de "Fichier source Sage"
   - Sélectionnez le fichier TXT exporté depuis Sage

3. **Choisissez le dossier de sortie** :
   - Par défaut : Vos Documents
   - Ou cliquez sur "Parcourir" pour changer

4. **Remplissez les informations** :
   - Période : Ex: "Septembre 2025"
   - Cabinet : Nom de votre cabinet
   - Client : Nom du client

5. **Générez** : Cliquez sur "Générer les rapports"

6. **Résultats** : Fichiers Excel et PowerPoint créés dans le dossier de sortie

### Utilisation Avancée

Consultez le **GUIDE_UTILISATEUR.md** pour :
- Enrichir les commentaires
- Formater le texte (gras, italique, puces)
- Sauvegarder et charger les commentaires
- Résoudre les problèmes courants

## 💻 Prérequis Système

### Configuration Requise

- **OS** : Windows 10 ou supérieur (64-bit)
- **RAM** : 4 GB minimum
- **Disque** : 500 MB libre
- **Logiciels** : Microsoft Excel (pour l'automatisation)

### Dépendances

✅ **Tout est inclus dans l'exécutable !**

Aucune installation de Python, bibliothèques ou autres logiciels n'est nécessaire.

## 🔒 Sécurité et Antivirus

### Détection Antivirus (Faux Positifs)

Certains antivirus peuvent détecter l'exécutable comme suspect. C'est un **faux positif** courant avec les applications PyInstaller.

**Solutions** :

1. **Windows Defender** :
   - Clic droit sur `RapportComptable.exe`
   - "Analyser avec Windows Defender"
   - Autorisez l'exécution

2. **Ajoutez une exception** :
   - Paramètres Windows → Sécurité Windows
   - Protection contre les virus
   - Gérer les paramètres
   - Exclusions → Ajouter une exclusion
   - Sélectionnez le dossier `RapportComptable_v1.0`

3. **Vérifiez l'intégrité** :
   - Demandez au fournisseur le hash SHA256 de l'exe
   - Comparez avec : `certutil -hashfile RapportComptable.exe SHA256`

### Confidentialité des Données

- ✅ **Aucune donnée n'est envoyée sur Internet**
- ✅ **Traitement 100% local sur votre PC**
- ✅ **Pas de télémétrie, pas de tracking**
- ✅ **Code source non accessible** (compilé)

## 📞 Support

### En cas de problème

1. **Consultez le GUIDE_UTILISATEUR.md** (FAQ incluse)

2. **Vérifiez les logs** :
   - Un dossier `logs` est créé automatiquement
   - Fichier : `logs/rapport_YYYY-MM-DD.log`

3. **Contactez le support** :
   - Email : support@votrecabinet.com
   - Téléphone : +33 X XX XX XX XX
   - Joignez le fichier de log si possible

### Informations Utiles pour le Support

Ayez sous la main :
- Version de Windows (Windows 10/11)
- Message d'erreur exact
- Fichier de log (`logs/rapport_YYYY-MM-DD.log`)
- Étapes pour reproduire le problème

## 📝 Notes de Version

### Version 1.0 (2025)

**Fonctionnalités** :
- ✅ Interface graphique complète en français
- ✅ Configuration intuitive en 2 étapes
- ✅ Génération automatique Excel + PowerPoint
- ✅ Design professionnel des rapports
- ✅ Enrichissement des commentaires avec formatage
- ✅ Sauvegarde/Chargement des commentaires
- ✅ Dates et noms dynamiques dans les rapports
- ✅ Logs détaillés pour débogage

**Formats supportés** :
- Entrée : TXT ou CSV depuis Sage
- Sortie : XLSX (Excel) + PPTX (PowerPoint)

**Limitations** :
- Windows uniquement (pas de Mac/Linux)
- Microsoft Excel requis

## 📄 Licence

© 2025 Votre Cabinet Comptable

Ce logiciel est fourni "tel quel", sans garantie d'aucune sorte.

Consultez le fichier **LICENSE** pour les détails.

## 🔄 Mises à Jour

Pour obtenir la dernière version :
- Contactez votre fournisseur
- Email : support@votrecabinet.com

Les mises à jour incluent :
- Nouvelles fonctionnalités
- Corrections de bugs
- Améliorations de performance

## ❓ Questions Fréquentes Rapides

### Q : Dois-je installer quelque chose ?
**R** : Non ! Juste double-cliquer sur l'exe.

### Q : Puis-je copier l'exe sur une clé USB ?
**R** : Oui, l'application est portable.

### Q : Où sont mes rapports générés ?
**R** : Par défaut dans "Mes Documents", ou le dossier que vous choisissez.

### Q : Puis-je modifier les rapports après génération ?
**R** : Oui ! Les fichiers Excel et PowerPoint sont modifiables normalement.

### Q : L'application fonctionne sans Internet ?
**R** : Oui, 100% hors ligne.

---

## 🎯 Démarrage Rapide (30 secondes)

1. **Double-clic** sur `RapportComptable.exe`
2. **Sélectionnez** votre fichier Sage TXT
3. **Remplissez** période, cabinet, client
4. **Cliquez** "Générer les rapports"
5. **Récupérez** vos fichiers Excel et PowerPoint !

---

**Bon reporting ! 📊✨**

Pour plus de détails, consultez le **GUIDE_UTILISATEUR.md**
