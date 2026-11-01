# Design

## Context

- `Campaign#close!` n'est appelée que par `CampaignsController#close` (bouton manuel) ; `closed!` met le statut à `closed`, état final. `Campaign#accepting_answers?` vaut `running? && deadline_on >= Date.current`.
- « A répondu » se lit `Respondent#submitted?`, donc `submitted_at`. Le seul code qui pose `submitted_at` en production est `Respondent#submit!`, appelé par `RespondentFormsController#submit` ; il refuse hors `accepting_answers?` et avec des notes manquantes. Les tests existants posent `submitted_at` directement avec `update!` : ils ne passent pas par `submit!` et ne déclencheront pas la règle.
- La page du sondé affiche d'abord « Vous avez soumis vos réponses » si `submitted?`, et seulement ensuite « campagne terminée » : un sondé dont la soumission a clos la campagne voit déjà le bon message.
- Trois mailers existent (`RespondentMailer`, `InvitationMailer`, `LoginLinkMailer`), tous sur le layout `mailer` (habillage commun, version HTML et texte, `email_address_with_name`), mis en file par `deliver_later` avec Solid Queue. L'expéditeur vient de `Fideback::MailerSettings`.
- SQLite n'accepte qu'un écrivain à la fois : deux soumissions simultanées s'exécutent l'une après l'autre.
- `campaigns/show` affiche le statut et une barre d'actions ; la classe `.callout` sert aux bandeaux d'état dans la page.

## Goals / Non-Goals

**Goals:**
- Une clôture déduite du fait (tous ont soumis), sans réglage, sans colonne, sans migration.
- Une clôture qui n'a lieu et n'envoie son e-mail qu'une fois, même en cas de soumissions simultanées.
- Une clôture indépendante de la livraison de l'e-mail.

**Non-Goals:**
- Pas de clôture rétroactive des campagnes existantes, pas de tâche planifiée.
- Pas de clôture automatique à la date limite.
- Pas d'enregistrement de la cause de la clôture : « tous les sondés ont répondu » se déduit de l'état des sondés.

## Decisions

### 1. Déclencher à la fin de `Respondent#submit!`

`submit!` pose `submitted_at`, puis appelle `campaign.close_when_complete!`. Une seule porte d'entrée : tout chemin qui soumet vraiment passe par là, et aucun contrôleur ne change.

*Écarté :* un callback `after_save` sur `Respondent` dès que `submitted_at` change. Il se déclencherait aussi pour les écritures directes des tests et des futures données de rattrapage, et cacherait la règle dans un callback.

### 2. Une clôture atomique qui dit si elle a eu lieu

`Campaign#close_when_complete!` ne fait rien si `all_submitted?` est faux (`respondents.where(submitted_at: nil)` n'existe pas, évalué en base et non sur l'association chargée). Sinon, elle fait passer le statut de `running` à `closed` par un `UPDATE ... WHERE id = ? AND status = running` et renvoie vrai uniquement si une ligne a changé. Seule l'exécution qui a gagné met l'e-mail en file.

Cela règle deux soumissions simultanées : SQLite sérialise les écritures, chacune valide son `submitted_at` avant de tester ; la dernière voit tout le monde soumis, et la mise à jour conditionnelle ne réussit qu'une fois.

*Écarté :* appeler `close!` et ignorer l'erreur. Cela passerait par une exception pour un cas normal, et ne dirait pas qui a gagné.

### 3. Un e-mail mis en file après la clôture, sans effet sur elle

Après une clôture réussie, `CampaignMailer.completed(campaign).deliver_later`. L'envoi est asynchrone : la soumission du sondé n'attend pas, et un échec d'envoi (retentatives de Solid Queue, ou erreur SMTP) n'annule rien. Le mail est mis en file hors de la transaction de la clôture.

Contenu : salutation « Bonjour <nom>, », objet « Tous vos sondés ont répondu : campagne clôturée », nom de la campagne, nombre de sondés qui ont répondu, bouton « Voir la synthèse » vers `campaign_url`, sur le layout `mailer` et son habillage commun. L'adresse du lien suit `APP_HOST` comme les autres e-mails.

*Écarté :* un lien direct vers la synthèse d'un managé. Elle est par managé (`summaries/:subject_id`) : la page de la campagne les liste tous.

### 4. Une ligne d'état déduite, pas une colonne

`campaigns/show` affiche un `.callout` « Clôturée : tous les sondés ont répondu » quand `closed? && all_submitted?`. Elle reste vraie même si le manager avait clôturé à la main alors que tous avaient déjà répondu, et elle ne l'est pas quand il a clôturé avec des manquants. Aucune colonne `closed_by` : elle n'apporterait rien d'observable de plus, et poserait la question des campagnes déjà clôturées.

### 5. Aucun changement côté sondé

Le contrôleur `submit` redirige déjà avec « Merci ! Vos réponses ont été soumises. » et la page montre « soumis » avant « terminée ». Un test d'intégration fige ce comportement pour la soumission qui clôt la campagne.

## Risks / Trade-offs

- [Le dernier sondé soumet par erreur avant d'avoir fini, ou une soumission est faite par un tiers avec son lien] → La soumission est déjà irréversible et confirmée par la boîte de confirmation ; la clôture n'ajoute pas de nouveau risque pour ses réponses, seulement celui de fermer la campagne, ce qui est le but.
- [Un manager voulait garder la campagne ouverte] → Décision prise : la règle est toujours active. Les réponses étant soumises, personne n'a plus rien à ajouter.
- [L'e-mail n'arrive pas] → La page de la campagne affiche la ligne d'état ; l'e-mail est une information, pas une étape.
- [Les campagnes déjà en cours avec tous les sondés soumis restent en cours] → Annoncé : la règle s'applique à la prochaine soumission. Un manager peut les clôturer à la main.
- [Un test existant clôture après avoir fait soumettre tout le monde par `submit!`] → Aucun test actuel n'utilise `submit!` ; le parcours système est adapté dans la tâche dédiée.

## Migration Plan

Aucune donnée ni migration. Déploiement ordinaire ; retour arrière par `git revert`, les campagnes clôturées automatiquement le restant.
