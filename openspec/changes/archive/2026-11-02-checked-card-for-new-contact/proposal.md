# Proposal

## Why

Dans le formulaire de campagne, un contact de l'annuaire se présente comme une fiche cochée et teintée, alors qu'un « Nouveau contact » n'est qu'une ligne de champs nue. Le manager ne voit pas que le nouveau contact sera bien ajouté à la liste, comme s'il l'avait coché.

## What Changes

- Une ligne de nouveau contact est entourée comme une fiche, avec la bordure, le fond teinté et l'ombre d'un contact existant coché.
- Une case cochée, purement visuelle, précède les champs Nom et E-mail.
- Aucun changement de comportement : la case n'est pas interactive et n'est pas envoyée avec le formulaire. « Supprimer » reste le seul moyen de retirer la ligne.

## Capabilities

### New Capabilities

### Modified Capabilities

Aucune : le comportement observable du spec `feedback-campaigns` ne change pas, seul l'habillage de la ligne évolue (`skip_specs: true`).

## Impact

- `app/views/campaigns/_new_contact_fields.html.erb`
- `app/assets/stylesheets` (styles `.contact`, y compris la version mobile)
- Tests d'intégration et système des campagnes à ajuster si besoin
