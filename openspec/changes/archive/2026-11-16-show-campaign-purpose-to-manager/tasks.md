# Tasks

## 1. Bloc partagé

- [x] 1.1 Extraire le bloc du motif de `respondent_forms/show` dans le partiel `campaigns/_purpose` (rien si vide ou blanc), l'utiliser dans `respondent_forms/show`, et vérifier que les tests de `respondent_forms_test.rb` sur le motif passent sans modification
- [x] 1.2 Sortir `.campaign-purpose` de la section « Formulaire du sondé » de la feuille de style, avec un espacement bas pour les deux pages, et vérifier visuellement que la page du sondé est inchangée

## 2. Page de la campagne

- [x] 2.1 Appeler le partiel dans `campaigns/show`, juste après l'en-tête et avant l'avis de clôture et les boutons, et vérifier par des tests d'intégration : avec motif (brouillon, en cours, clôturée), sans motif ni espaces seuls (aucun bloc), HTML échappé et retours à la ligne conservés, bloc placé avant les boutons d'action
- [x] 2.2 Vérifier visuellement `/campaigns/:id` avec un motif court et un motif de 1000 caractères, sur grand écran et sous 40rem

## 3. Vérification d'ensemble

- [x] 3.1 Lancer `bin/ci` et `bin/rails test:system`, et vérifier qu'ils passent
