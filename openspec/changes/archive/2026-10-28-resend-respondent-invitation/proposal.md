# Proposal

## Why

Une invitation peut se perdre (spam, mauvaise boîte, email supprimé). Aujourd'hui le manager ne peut pas la renvoyer à un sondé d'une campagne en cours, et rien n'indique si ou quand une invitation est partie.

## What Changes

- Bouton « Renvoyer » par sondé sur la page d'une campagne en cours, qui renvoie l'email d'invitation avec le même lien personnel.
- Le bouton n'est proposé, et l'action n'est acceptée, que si la campagne accepte encore des réponses et que le sondé n'a pas soumis.
- Nouvelle colonne `respondents.last_invited_at`, datée à la mise en file de l'email, au lancement comme au renvoi.
- Colonne « Invité le … » dans le tableau des sondés.
- Migration avec backfill de `last_invited_at` pour les campagnes déjà lancées.

## Capabilities

### New Capabilities

### Modified Capabilities
- `feedback-campaigns`: nouveau requirement de renvoi d'invitation ; le lancement date les invitations ; le suivi d'avancement affiche la date de dernière invitation.

## Impact

- Code : `Respondent`, `Campaign#launch!`, `CampaignsController` ou nouveau `RespondentsController`, routes, `campaigns/show`, locales.
- Base de données : migration ajoutant `respondents.last_invited_at`.
- Hors périmètre : compteur ou historique d'envois, confirmation de livraison SMTP, limitation de fréquence des renvois.
