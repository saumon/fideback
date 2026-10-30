# Proposal

## Why

Sur la page « Mot de passe oublié ? », le bouton s'intitule « Envoyez-moi des instructions pour réinitialiser mon mot de passe ». Ce libellé est trop long pour la mise en page :
- sur ordinateur, à 1000 px de large, le bouton déborde de la carte du formulaire ;
- sur téléphone, à 360 px, il sort de l'écran et le texte est coupé à « réin… ».

Le titre de la page dit déjà de quoi il s'agit, le bouton n'a pas besoin de le répéter.

## What Changes

- Le bouton de la page « Mot de passe oublié ? » s'intitule « Envoyez-moi les instructions ».
- Le formulaire, son fonctionnement et le message affiché après l'envoi ne changent pas.

Hypothèse retenue : seul ce bouton est concerné. Les autres boutons du parcours d'authentification tiennent déjà dans leur carte, par exemple « Recevoir un nouveau lien » sur la page de renvoi de l'e-mail d'activation.

## Capabilities

### New Capabilities

Aucune.

### Modified Capabilities
- `manager-auth` : l'exigence « Réinitialisation du mot de passe » gagne un scénario. Il fixe le libellé du bouton de demande et impose qu'il reste entièrement visible dans le formulaire, y compris sur un écran de téléphone.

## Impact

- Traductions : `config/locales/devise.views.fr.yml`, clé `devise.passwords.new.send_me_reset_password_instructions`.
- Tests : un test d'intégration vérifie le libellé du bouton sur la page de mot de passe oublié.
- Aucun changement de vue, de CSS, de route ni de dépendance.
