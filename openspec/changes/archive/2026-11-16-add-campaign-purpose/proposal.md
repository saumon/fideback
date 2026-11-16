# Proposal

## Why

Un sondé qui reçoit une invitation ne sait pas pourquoi on lui demande son avis. L'e-mail actuel suppose en outre que la campagne prépare des entretiens individuels, alors qu'un manager peut recueillir du feedback à tout moment de l'année, pour d'autres raisons.

## What Changes

- La campagne reçoit un champ facultatif « Pourquoi cette campagne ? », limité à 1000 caractères, saisi dans le formulaire de campagne.
- S'il est renseigné, ce texte est affiché en tête du formulaire de réponse du sondé et dans l'e-mail d'invitation. Sinon, rien n'apparaît.
- L'e-mail d'invitation (versions HTML et texte) ne dit plus que le manager « prépare ses entretiens individuels » : la phrase devient neutre.

## Capabilities

### New Capabilities

### Modified Capabilities
- `feedback-campaigns`: la création et la modification d'une campagne acceptent le motif facultatif, limité à 1000 caractères.
- `feedback-submission`: l'e-mail d'invitation n'évoque plus d'entretiens individuels et reprend le motif s'il existe ; le formulaire de réponse l'affiche aussi.

## Impact

- Base de données : une colonne `purpose` (texte, facultative) sur `campaigns`, avec migration.
- Code : modèle `Campaign`, `CampaignsController` (paramètres autorisés), formulaire de campagne, page `respondent_forms/show`, e-mail `respondent_mailer/invitation` (HTML et texte), libellés `fr.yml`.
- Hors périmètre : la page d'accueil, l'e-mail d'invitation de manager et le texte de but de `feedback-synthesis`, qui parlent aussi d'entretiens individuels.
