## Requêtes de Correction et d'Amélioration pour l'Agent IA (Version 2.0 - Auto-Correction)

### 1. Corrections sur le Bilan

| ID | Type | Composant | Description du Problème | Action Requise (Axée sur la Logique) |
| :--- | :--- | :--- | :--- | :--- |
| **BL-01** | Bug | Bilan (Actif) | Le libellé du poste "fournisseurs, débiteurs" (montant 119 900) est incorrect. Ce montant représente un paiement anticipé pour lequel la facture n'a pas été reçue. Le libellé attendu est **"Fournisseur, facture non parvenue"** (compte 40.85). | **Vérifier la logique de mapping** entre les numéros de compte (40.85) et les libellés affichés dans le rapport de Bilan. **S'assurer de la cohérence** entre la nature du solde (paiement anticipé) et le libellé comptable approprié. |
| **BL-02** | Amélioration | Bilan (Passif/Actif) | Le regroupement des comptes bancaires masque la distinction entre les comptes à découvert et les comptes créditeurs (ex: un compte à découvert et un compte créditeur de 3 000 000 sont agrégés). | **Vérifier la présentation des comptes bancaires** pour s'assurer que la distinction entre les soldes débiteurs (Actif) et créditeurs (Passif) est correctement reflétée, ou fournir une ventilation plus détaillée si l'agrégation est maintenue. |

### 2. Corrections et Améliorations sur le Suivi d'Activité

| ID | Type | Composant | Description du Problème | Action Requise (Axée sur la Logique) |
| :--- | :--- | :--- | :--- | :--- |
| **SA-01** | Bug | Suivi d'Activité | Erreur de placement des totaux de charges : la somme annuelle des charges est incorrectement reportée dans la colonne du mois d'**Octobre** au lieu de la colonne **"Total Année"**. (Exemple : 1 000 000 pour l'assistance comptable est affiché en Octobre). | **Auditer la fonction de calcul des totaux** dans le rapport de Suivi d'Activité. **Vérifier la logique de sommation** pour garantir que les totaux annuels sont exclusivement affichés dans la colonne désignée "Total Année" et non dans une colonne mensuelle. |
| **SA-02** | Feature | Suivi d'Activité | Le rapport de Suivi d'Activité ne présente pas le résultat définitif (Produits - Charges). | **Ajouter une nouvelle ligne/cellule** à la fin du rapport de Suivi d'Activité pour calculer et afficher le **Résultat Définitif** (Produits Totaux - Charges Totales). |
| **SA-03** | Objectif | Cohérence des Rapports | Le client souhaite que le Résultat Définitif du Suivi d'Activité soit **identique** à celui du Bilan, du Compte de Résultat et de l'État Intermédiaire de Gestion. | **Assurer la cohérence des calculs** du résultat net entre tous les rapports financiers générés par le logiciel (Bilan, Compte de Résultat, État Intermédiaire de Gestion, et le nouveau champ dans le Suivi d'Activité). |
