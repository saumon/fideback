# Proposal

## Why

Une campagne ne se clôture aujourd'hui qu'à la main, ou de fait après sa date limite (les réponses sont refusées, mais le statut reste « en cours »). Quand tous les sondés ont déjà soumis leurs réponses, la campagne n'a plus rien à attendre : le manager doit pourtant revenir la clôturer, et il peut l'oublier, ce qui laisse en « en cours » une campagne terminée. La clôture doit suivre le fait, et le manager doit savoir que la synthèse est complète.

## What Changes

- Quand le dernier sondé soumet définitivement ses réponses, la campagne en cours **se clôture automatiquement**. La règle est toujours active : aucun réglage, ni par campagne ni global.
- Le manager reçoit alors **un e-mail** : « Tous vos sondés ont répondu : campagne clôturée », avec le nom de la campagne, le nombre de réponses et un bouton vers la campagne et sa synthèse. Il ne part qu'une fois, même si deux soumissions arrivent en même temps.
- La clôture ne dépend pas de l'e-mail : si l'envoi échoue, la campagne reste clôturée.
- La page d'une campagne clôturée dont tous les sondés ont répondu affiche une ligne d'état « Clôturée : tous les sondés ont répondu », dans la page et non en toast.
- Le dernier sondé voit la confirmation habituelle de sa soumission, pas le message « campagne terminée ».
- La clôture manuelle et la date limite ne changent pas. Les campagnes déjà en cours ne sont pas clôturées rétroactivement : la règle s'applique à la prochaine soumission.

## Capabilities

### New Capabilities

(aucune)

### Modified Capabilities
- `feedback-campaigns`: ajout de la clôture automatique par la soumission du dernier sondé, de l'e-mail envoyé au manager et de la ligne d'état d'une campagne terminée.
- `feedback-submission`: ajout de la confirmation montrée au sondé dont la soumission clôt la campagne.

## Impact

- **Modèles** : `Respondent#submit!` déclenche la vérification, `Campaign` gagne une clôture atomique qui indique si elle a eu lieu et une méthode `all_submitted?`.
- **E-mail** : un nouveau mailer `CampaignMailer#completed` avec ses vues HTML et texte, sur l'habillage commun existant, mis en file avec `deliver_later`.
- **Vues** : `campaigns/show` (ligne d'état d'une campagne terminée).
- **Données** : aucune migration, aucune colonne ajoutée.
- **Tests** : modèle (déclenchement, atomicité, cas limites), mailer, intégration (soumission, e-mail, page du manager), système (parcours complet jusqu'à la clôture automatique).
- **Documentation** : `docs/fonctionnement.md` et la liste *Fonctionnalités* du README.
- **Hors périmètre** : clôture rétroactive des campagnes existantes, réglage pour désactiver la règle, relance automatique des sondés, clôture automatique à la date limite.
