# Proposal

## Why

À chaque nouvelle campagne, le manager ressaisit à la main le nom et l'e-mail de chaque managé et de chaque sondé. C'est long, et une faute de frappe dans un e-mail fait partir une invitation dans le vide. Les mêmes personnes reviennent pourtant d'une campagne à l'autre : il leur faut une liste persistante, tenue une fois, dans laquelle on pioche.

## What Changes

- Nouvel annuaire par manager : chaque contact a un nom, un e-mail unique dans l'annuaire, et un ou deux rôles parmi « managé » et « sondable ».
- Nouvel écran « Mon équipe », accessible depuis la navigation principale, pour ajouter, modifier et supprimer des contacts sans recharger la page, avec un filtre Tous / Managés / Sondables.
- **BREAKING** (comportement du formulaire) : dans le formulaire de campagne, les sections Managés et Sondés ne sont plus des lignes libres. Ce sont des cases à cocher alimentées par l'annuaire et filtrées par rôle, toutes décochées à la création, avec un bouton « Tout cocher » par section.
- Chaque section garde un bouton « Nouveau contact » : une personne ajoutée ainsi entre dans l'annuaire avec le rôle de la section, puis elle est sélectionnée. Si son e-mail existe déjà dans l'annuaire, le contact existant est réutilisé et le rôle lui est ajouté.
- Les managés et sondés d'une campagne restent des copies propres à la campagne. Tant que la campagne est brouillon, ils suivent l'annuaire : un contact modifié est mis à jour, et un contact supprimé ou privé du rôle est retiré. Une fois la campagne lancée, ils sont figés.
- À la mise en service, l'annuaire de chaque manager est pré-rempli à partir de ses campagnes existantes.
- Hors périmètre : import en masse (CSV ou liste collée).

## Capabilities

### New Capabilities
- `team-directory` : annuaire persistant des contacts d'un manager, rôles managé / sondable, écran de gestion, isolation entre managers, répercussion sur les campagnes brouillon.

### Modified Capabilities
- `feedback-campaigns` : les managés et les sondés d'une campagne sont choisis dans l'annuaire au lieu d'être saisis librement ; le formulaire de campagne et ses lignes initiales changent en conséquence.

## Impact

- Base de données : nouvelle table `contacts`, colonne `contact_id` facultative sur `subjects` et `respondents`, migration de reprise des données existantes.
- Modèles : nouveau `Contact`, `Manager has_many :contacts`, sélection des contacts dans `Campaign`.
- Contrôleurs et routes : nouveau contrôleur de l'annuaire, `CampaignsController` (paramètres de sélection et nouveaux contacts).
- Vues : nouvel écran d'annuaire, `campaigns/_form.html.erb` et partials de contacts, lien dans `layouts/application.html.erb`, styles dans `application.css`.
- JavaScript : réutilisation de `nested_form_controller.js` ; petit contrôleur Stimulus pour le filtre et « Tout cocher ».
- Tests : `test/integration/campaigns_test.rb`, `test/system/feedback_journey_test.rb` et fixtures à adapter ; nouveaux tests de modèle et d'intégration pour l'annuaire.
- Aucune dépendance ajoutée.
