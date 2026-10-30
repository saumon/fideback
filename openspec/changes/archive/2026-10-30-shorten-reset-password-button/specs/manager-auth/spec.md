# Spec Delta

## MODIFIED Requirements

### Requirement: Réinitialisation du mot de passe
Le système SHALL permettre à un manager de réinitialiser son mot de passe via un lien envoyé par e-mail.

#### Scenario: Demande de réinitialisation
- **WHEN** un manager saisit l'e-mail de son compte sur la page de mot de passe oublié
- **THEN** un e-mail contenant un lien de réinitialisation à durée limitée lui est envoyé

#### Scenario: E-mail inconnu
- **WHEN** un visiteur saisit un e-mail sans compte
- **THEN** la réponse affichée est identique à celle d'un e-mail connu, sans révéler l'existence du compte

#### Scenario: Bouton de demande lisible
- **WHEN** un visiteur ouvre la page de mot de passe oublié, sur ordinateur ou sur un écran de téléphone de 360 px de large
- **THEN** le bouton d'envoi s'intitule « Envoyez-moi les instructions » et tient entièrement dans la carte du formulaire, sans texte coupé
