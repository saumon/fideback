# Proposal

## Why

Un manager ne peut supprimer une campagne que tant qu'elle est en brouillon. Une fois la campagne lancée puis clôturée, elle reste dans sa liste pour toujours, même quand son entretien est passé et que ses données n'ont plus d'usage. Par ailleurs, la suppression n'est protégée que par l'interface : le serveur supprime une campagne de n'importe quel état à la réception de la requête, y compris une campagne en cours dont des sondés sont en train de répondre. Rien ne l'écrit dans les spécifications, et aucun test ne l'exerce.

## What Changes

- Le créateur d'une campagne peut **supprimer une campagne clôturée**, avec le bouton « Supprimer » déjà utilisé pour les brouillons, sur la page de la campagne.
- **Le serveur refuse** de supprimer une campagne **en cours**, avec le message « Cette campagne est en cours : clôturez-la avant de la supprimer. ». Une campagne brouillon ou clôturée est supprimable ; la règle est appliquée côté serveur, pas seulement par l'interface.
- Pour une campagne clôturée, la boîte de confirmation (rouge, focus sur « Non, revenir ») **chiffre ce qui sera perdu** : « Les réponses de 2 sondés sur 3 et la synthèse seront perdues. Cette action est définitive. ». Le texte du brouillon ne change pas.
- La suppression emporte la campagne, ses managés, ses sondés, leurs réponses et ses questions. L'annuaire d'équipe du manager n'est pas touché. Les liens personnels des sondés répondent « page introuvable ».
- Une campagne d'un autre manager reste introuvable, et un visiteur non connecté est renvoyé à la connexion.

## Capabilities

### New Capabilities

(aucune)

### Modified Capabilities
- `feedback-campaigns`: deux exigences ajoutées, « Suppression d'une campagne » (états, refus en cours, cascade, annuaire intact, isolation) et « Confirmation chiffrée de la suppression d'une campagne clôturée ».

## Impact

- **Contrôleur** : `CampaignsController#destroy` vérifie l'état avant de supprimer. Le garde n'est pas un callback du modèle : supprimer le compte d'un manager supprime ses campagnes, quel que soit leur état, et doit continuer à le faire.
- **Vues** : `campaigns/show` (bouton « Supprimer » pour une campagne clôturée, détail de la boîte chiffré) et un assistant `CampaignsHelper` pour le texte du détail.
- **Tests** : aucun test n'appelle `destroy` aujourd'hui. Intégration (chaque état, cascade, isolation, accès sans connexion, texte de la boîte), système (suppression d'une campagne clôturée par la boîte).
- **Documentation** : `docs/fonctionnement.md`.
- **Données** : aucune migration.
- **Hors périmètre** : export de la synthèse avant suppression, bouton de suppression dans la liste des campagnes, suppression d'une campagne en cours, archivage au lieu de suppression, corbeille ou annulation.
