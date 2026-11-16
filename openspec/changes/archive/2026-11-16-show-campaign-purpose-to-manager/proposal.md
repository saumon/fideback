# Proposal

## Why

Le motif d'une campagne (« Pourquoi cette campagne ? ») est saisi dans le formulaire, mais le manager ne le revoit nulle part : la page de la campagne ne l'affiche pas, et « Modifier » n'existe qu'en brouillon. Une fois la campagne lancée, il ne peut plus relire ce que ses sondés voient.

## What Changes

- La page d'une campagne (`/campaigns/:id`) affiche le motif, juste sous l'en-tête et avant les boutons d'action, quel que soit l'état de la campagne.
- Sans motif (vide ou espaces seuls), rien n'apparaît : pas de rappel, pas de bloc vide, pas d'invitation à le renseigner.
- Le bloc est le même que celui du formulaire de réponse du sondé, partagé entre les deux pages.

## Capabilities

### New Capabilities

### Modified Capabilities
- `feedback-campaigns`: un nouveau requirement précise que la page de la campagne affiche le motif lorsqu'il est renseigné.

## Impact

- Code : vue `campaigns/show`, vue `respondent_forms/show` (reprise du bloc partagé), nouveau partiel de bloc, feuille de style.
- Aucune migration, aucun changement de modèle, de contrôleur ou d'e-mail.
- Hors périmètre : la liste des campagnes (`/campaigns`), qui n'affiche pas le motif.
