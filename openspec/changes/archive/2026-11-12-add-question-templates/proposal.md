# Proposal

## Why

Les questions envoyées aux sondés sont un jeu unique codé en dur (`Campaign::DEFAULT_QUESTIONS`). Un manager qui mène des campagnes de natures différentes (bilan annuel, fin de projet, onboarding) doit réécrire ses questions à chaque création. Il faut pouvoir garder des questionnaires réutilisables.

## What Changes

- Nouvel écran « Mes modèles » (entrée de la navigation principale) où un manager ajoute, modifie et supprime ses modèles de questions.
- Un modèle par défaut, fourni par le système, identique pour tous les managers, visible mais non modifiable ni supprimable. Son contenu reprend les quatre questions aujourd'hui codées en dur, qui cessent de l'être.
- Le formulaire de création d'une campagne propose un sélecteur de modèle, le modèle par défaut étant présélectionné. Changer de modèle remplace aussitôt les questions du formulaire par celles du modèle, sans recharger la page ni perdre le reste de la saisie, et sans confirmation.
- Les questions du formulaire restent librement modifiables après le choix d'un modèle ; les questions d'une campagne sont des copies et ne gardent aucun lien avec le modèle.
- Aucun sélecteur à la modification d'une campagne brouillon.

## Capabilities

### New Capabilities
- `question-templates`: modèles de questions (modèle système par défaut, modèles propres à chaque manager), leur gestion et leur isolation entre managers.

### Modified Capabilities
- `feedback-campaigns`: le jeu de questions initial d'une campagne vient du modèle choisi (défaut ou autre) au lieu d'un jeu codé en dur.
- `main-navigation`: nouvelle entrée « Mes modèles », signalée comme page courante sur les écrans de modèles.

## Impact

- Base de données : tables des modèles et de leurs questions ; migration créant le modèle système.
- Code : `Campaign::DEFAULT_QUESTIONS` et `build_default_questions` (remplacés), `CampaignsController#new`, formulaire de campagne, nouveau contrôleur de modèles et contrôleur Stimulus du sélecteur, navigation et `current_nav_section`.
- Tests : modèles, intégration (CRUD, isolation, sélection), navigation, système pour le remplacement des questions.
- Aucune campagne existante n'est modifiée.
