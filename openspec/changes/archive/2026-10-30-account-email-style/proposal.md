# Proposal

## Why

L'invitation envoyée aux sondés au démarrage d'une campagne porte l'habillage de Fideback : fond clair, nom « Fideback » en tête, bandeau aux six couleurs et carte bordée d'encre. Les e-mails envoyés aux managers ne l'ont pas. L'e-mail d'activation de compte et celui de réinitialisation du mot de passe arrivent comme du texte brut sur fond blanc, avec seulement le bouton stylé. Ces deux e-mails ressemblent alors à un message générique, voire à de l'hameçonnage, juste au moment où le manager doit cliquer sur un lien sensible.

## What Changes

- Les e-mails envoyés aux managers reprennent le même habillage que l'invitation des sondés :
  - activation du compte ;
  - confirmation d'une nouvelle adresse e-mail, qui utilise le même modèle ;
  - réinitialisation du mot de passe.
- L'e-mail de réinitialisation du mot de passe s'aligne sur l'invitation :
  - il gagne une version texte, en plus de la version HTML, comme l'invitation et l'activation ;
  - il salue le manager par son nom, suivi d'une virgule (« Bonjour Alice, »), et non plus par son adresse e-mail suivie d'un point d'exclamation.
- Les textes, les objets et les liens des e-mails ne changent pas par ailleurs.

Hypothèses retenues, à corriger si besoin :
- Le « changement de mot de passe » désigne l'e-mail de mot de passe oublié, celui qui contient le lien de réinitialisation. Les notifications Devise « mot de passe modifié » et « adresse modifiée » sont désactivées dans l'application et restent hors périmètre. Si elles sont activées plus tard, elles recevront l'habillage automatiquement.
- Le « style » couvre l'habillage commun, le bouton et le ton de la salutation. Les formulations des messages ne sont pas réécrites.

## Capabilities

### New Capabilities
- `mail-appearance` : apparence des e-mails envoyés par Fideback. Elle couvre l'habillage commun à tous les e-mails, la présence d'une version texte et la forme de la salutation.

### Modified Capabilities

Aucune. `mail-delivery` porte sur l'acheminement des e-mails (SMTP, expéditeur, liens), et `manager-auth` sur le contenu fonctionnel des parcours. Leurs exigences restent inchangées.

## Impact

- Configuration : `config/initializers/devise.rb`, pour que les e-mails de Devise passent par la classe d'e-mails de l'application et donc par son layout.
- Vues : `app/views/devise/mailer/reset_password_instructions.html.erb`, avec la salutation par le nom, et un nouveau `reset_password_instructions.text.erb`.
- Traductions : `config/locales/devise.views.fr.yml`, pour la salutation de la réinitialisation.
- Tests : nouveaux tests d'e-mails pour l'activation et la réinitialisation.
- Aucune nouvelle dépendance. L'expéditeur reste le même.
