# Design

## Context

- `ApplicationMailer` déclare `layout "mailer"` et l'expéditeur commun. `RespondentMailer` en hérite, et l'invitation est donc habillée par `layouts/mailer.html.erb` : en-tête « Fideback », bandeau à six couleurs et carte.
- `Devise::Mailer` hérite de `Devise.parent_mailer`, qui vaut par défaut `ActionMailer::Base` (réglage commenté dans `config/initializers/devise.rb`). Il ne trouve aucun layout : un rendu dans `bin/rails runner` le confirme, sans bandeau dans l'activation ni dans la réinitialisation.
- Les vues `devise/mailer/confirmation_instructions` (HTML + texte) et `reset_password_instructions` (HTML seul) ont déjà le bouton au style de l'invitation, écrit en ligne.
- La salutation de la réinitialisation est `Bonjour %{recipient} !`, appelée avec `@resource.email`. Celle de l'activation est `Bonjour %{recipient},`, appelée avec `@resource.name`.
- `send_password_change_notification` et `send_email_changed_notification` sont désactivés. Leurs vues ne sont pas surchargées.

## Goals / Non-Goals

**Goals:**
- Une seule définition de l'habillage, `layouts/mailer`, pour tous les e-mails.

**Non-Goals:**
- Factoriser le style en ligne du bouton, répété dans trois vues. Il est identique partout, et le déplacer dans un helper sortirait du périmètre.
- Surcharger les vues `password_change` et `email_changed` de Devise : ces e-mails ne sont pas envoyés.

## Decisions

### 1. `config.parent_mailer = "ApplicationMailer"`

Dans `config/initializers/devise.rb`, décommenter et régler `config.parent_mailer = "ApplicationMailer"`. `Devise::Mailer` hérite alors du layout `mailer` et de l'expéditeur par défaut, sans nouvelle classe. La documentation de Devise (wiki « How-To: Create custom layouts ») présente cette approche.

Un futur e-mail de Devise (déverrouillage, notifications) recevra aussi l'habillage, sans travail supplémentaire.

*Écarté :* `Devise::Mailer.layout "mailer"` dans un `config.to_prepare`. Cela fonctionne, mais l'héritage reste différent de celui des autres e-mails, et le réglage est placé loin de la configuration de Devise.

*Écarté :* une classe `ManagerMailer < Devise::Mailer` avec `config.mailer`. C'est une classe de plus pour un seul `layout`.

### 2. Version texte et salutation de la réinitialisation

- Créer `devise/mailer/reset_password_instructions.text.erb`, calqué sur `confirmation_instructions.text.erb` : salutation, instruction, puis `action : <url>` et les deux phrases finales. Le layout texte `mailer.text.erb` se contente de `yield`, comme pour l'invitation.
- Dans la vue HTML, passer `recipient: @resource.name`.
- Dans `devise.views.fr.yml`, changer `reset_password_instructions.greeting` en `"Bonjour %{recipient},"`.

Les salutations `password_change` et `email_changed` gardent leur forme Devise : ces e-mails ne sont pas envoyés.

### 3. Tests

Dans `test/mailers/`, ajouter un test des e-mails de Devise, sur le modèle de `respondent_mailer_test.rb`. Pour l'activation et la réinitialisation, il vérifie :
- la présence des parties texte et HTML ;
- la salutation avec le nom dans les deux parties ;
- le lien complet dans la partie texte ;
- dans la partie HTML, un marqueur du layout présent dans l'invitation, comme le texte de l'en-tête « Fideback » et le dégradé `linear-gradient` du bandeau.

Le même marqueur est vérifié sur l'invitation, pour que le test échoue si le layout change d'une façon qui casse la comparaison.

## Risks / Trade-offs

- **Ordre de chargement** : `parent_mailer` est une chaîne, résolue au premier chargement de `Devise::Mailer`, donc après les initializers. → Le risque est nul en pratique. Les tests d'e-mails confirment le rendu.
- **Expéditeur** : Devise pose l'expéditeur avec `mailer_sender`, et `ApplicationMailer` a le même par défaut. → Le test existant « share one sender » le garantit toujours.
- **Messageries qui ignorent `<style>`** : l'habillage est déjà écrit en styles en ligne dans le layout. Rien ne change sur ce point.
