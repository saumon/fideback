# Tasks

## 1. Règle côté serveur

- [x] 1.1 Ajouter `Campaign#deletable?` (faux seulement pour une campagne en cours) et faire refuser `CampaignsController#destroy` une campagne en cours (redirection vers la campagne, alerte « Cette campagne est en cours : clôturez-la avant de la supprimer. »), puis vérifier par des tests d'intégration : suppression d'un brouillon, d'une campagne clôturée (managés, sondés, réponses et questions supprimés), refus d'une campagne en cours qui reste intacte, annuaire d'équipe intact, lien d'un sondé introuvable après suppression, campagne d'un autre manager introuvable et intacte, visiteur renvoyé à la connexion
- [x] 1.2 Vérifier par un test que la suppression du compte d'un manager supprime aussi ses campagnes en cours (le garde ne doit pas s'y appliquer)

## 2. Interface

- [x] 2.1 Extraire le bouton « Supprimer » dans le partiel `campaigns/_delete_button.html.erb`, l'utiliser pour le brouillon et pour un nouveau bloc d'actions de la campagne clôturée (aucun bouton en cours), et ajouter `CampaignsHelper#delete_campaign_detail` pour les trois textes de détail, puis vérifier par des tests d'intégration sur la page : bouton présent pour le brouillon et la campagne clôturée, absent en cours, détail exact pour une campagne clôturée avec réponses (pluriel et singulier), sans réponse, et pour le brouillon (texte inchangé)

## 3. Parcours

- [x] 3.1 Créer un test système : un manager ouvre une campagne clôturée, clique sur « Supprimer », voit la boîte rouge avec le détail chiffré et le focus sur « Non, revenir », se retire (la campagne reste), recommence, confirme, retrouve sa liste sans la campagne avec « Campagne supprimée. » ; vérifier que `bin/rails test:system` passe en entier

## 4. Documentation et vérifications

- [x] 4.1 Mettre à jour `docs/fonctionnement.md` (suppression d'une campagne brouillon ou clôturée, refus en cours, boîte chiffrée, ce qui est supprimé et ce qui reste) et vérifier qu'aucune phrase ne contredit la règle
- [x] 4.2 Vérifier avec `openspec validate allow-deleting-closed-campaign --strict`, puis `bin/rails test`, `bin/rubocop`, `bin/rails test:system` et `bin/ci` au vert

## Workflow follow-up

- Archiver le changement avec `/opsx:archive` (synchronisation vers `feedback-campaigns`, deux exigences ajoutées), puis terminer avec `/saumon-finish`.
