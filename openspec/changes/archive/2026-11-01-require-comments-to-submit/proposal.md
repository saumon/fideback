# Proposal

## Why

Un sondé peut aujourd'hui soumettre définitivement ses réponses sans écrire un seul commentaire : seules les notes sont exigées. Le manager reçoit alors une synthèse nominative où des questions à commentaire restent vides, alors que ces commentaires sont la matière de l'entretien. La spécification parle déjà de « tous les commentaires requis » à la soumission : le code ne l'applique pas.

## What Changes

- Un sondé **ne peut plus soumettre définitivement** tant qu'il lui manque une note ou un commentaire, pour chaque managé et chaque question qui en attend. Un commentaire est valable dès qu'il contient **au moins un caractère qui n'est pas un espace** : « ok » passe, un champ vide ou fait d'espaces est refusé. Aucun minimum de longueur.
- La règle est **toujours active** : pas de case « obligatoire » par question, pas de réglage. Elle s'applique aussitôt aux campagnes en cours, sans toucher aux sondés qui ont déjà soumis.
- **Avant la soumission**, chaque note et chaque commentaire porte la mention « obligatoire pour soumettre », et un compteur indique combien de champs il reste à renseigner, mis à jour pendant la saisie.
- **Après un refus**, chaque champ manquant est signalé (« Note manquante », « Commentaire manquant »), la saisie est conservée, le message donne le nombre de champs manquants et le focus va au premier.
- « Enregistrer et continuer plus tard » reste permissif : il garde la saisie partielle.

## Capabilities

### New Capabilities

(aucune)

### Modified Capabilities
- `feedback-submission`: l'exigence « Soumission finale » exige aussi les commentaires, et deux exigences nouvelles décrivent l'annonce des champs obligatoires et le signalement après un refus.

## Impact

- **Modèle** : `Respondent#missing_ratings` devient `missing_answers` (notes et commentaires) ; `submit!` s'appuie dessus.
- **Contrôleur** : `RespondentFormsController#submit` (message avec le nombre de champs manquants).
- **Vue** : `respondent_forms/show` (mention, signalement par champ, compteur, premier champ manquant en `autofocus`).
- **JavaScript** : un contrôleur Stimulus `answer_progress` pour le compteur en direct.
- **CSS** : mention, compteur et signalement par champ dans `application.css`.
- **Tests** : modèle, intégration, système ; l'assistant `answer_fully` de `test_helper.rb` doit aussi remplir les commentaires.
- **Documentation** : `docs/fonctionnement.md`.
- **Données** : aucune migration.
- **Hors périmètre** : un minimum de longueur, une case « obligatoire » par question, la clôture automatique et l'e-mail au manager (inchangés), la synthèse.
