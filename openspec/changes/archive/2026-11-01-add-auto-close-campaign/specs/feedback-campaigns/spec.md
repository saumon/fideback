# Spec Delta

## ADDED Requirements

### Requirement: Clôture automatique à la dernière soumission
Le système SHALL clôturer automatiquement une campagne en cours dès que tous ses sondés ont soumis définitivement leurs réponses. Cette règle MUST s'appliquer à toute campagne, sans réglage.

#### Scenario: Dernier sondé
- **WHEN** le dernier sondé d'une campagne en cours soumet ses réponses alors que tous les autres ont déjà soumis
- **THEN** la campagne passe à l'état clôturée et les liens des sondés n'acceptent plus de réponse

#### Scenario: Il reste des sondés
- **WHEN** un sondé soumet ses réponses alors qu'un autre sondé de la campagne n'a pas encore soumis
- **THEN** la campagne reste en cours

#### Scenario: Réponses non soumises
- **WHEN** un sondé a enregistré des réponses sans les soumettre définitivement et que tous les autres ont soumis
- **THEN** la campagne reste en cours

#### Scenario: Campagne à un seul sondé
- **WHEN** l'unique sondé d'une campagne en cours soumet ses réponses
- **THEN** la campagne passe à l'état clôturée

#### Scenario: Soumission après la date limite
- **WHEN** un sondé tente de soumettre ses réponses après la date limite de la campagne
- **THEN** la soumission est refusée et l'état de la campagne ne change pas

#### Scenario: Clôture simultanée
- **WHEN** les deux derniers sondés soumettent au même instant
- **THEN** la campagne est clôturée une seule fois

#### Scenario: Campagnes déjà en cours
- **WHEN** la règle est mise en service alors qu'une campagne en cours a déjà toutes ses soumissions
- **THEN** cette campagne n'est pas clôturée tant qu'aucune nouvelle soumission n'a lieu

### Requirement: E-mail au manager à la clôture automatique
Le système SHALL envoyer au manager, quand sa campagne est clôturée automatiquement, un e-mail qui annonce que tous ses sondés ont répondu, donne le nom de la campagne et le nombre de réponses, et mène à la campagne et à sa synthèse. Cet e-mail MUST partir une seule fois par campagne.

#### Scenario: Envoi à la clôture
- **WHEN** la soumission du dernier sondé clôture la campagne « Entretiens 2026 »
- **THEN** son manager reçoit un e-mail dont l'objet est « Tous vos sondés ont répondu : campagne clôturée », qui nomme la campagne, donne le nombre de réponses et propose un bouton vers la campagne

#### Scenario: Salutation et habillage
- **WHEN** le manager Alice Manager reçoit cet e-mail
- **THEN** il commence par « Bonjour Alice Manager, » dans ses versions HTML et texte, avec l'habillage commun des e-mails

#### Scenario: Aucun e-mail sans clôture automatique
- **WHEN** un manager clôture lui-même sa campagne, ou qu'un sondé soumet sans que tous aient répondu
- **THEN** aucun e-mail de clôture automatique n'est envoyé

#### Scenario: Envoi unique
- **WHEN** deux soumissions simultanées clôturent la même campagne
- **THEN** le manager ne reçoit qu'un seul e-mail

#### Scenario: Échec de l'envoi
- **WHEN** l'envoi de l'e-mail échoue
- **THEN** la campagne reste clôturée et les réponses des sondés restent soumises

### Requirement: Cause de la clôture affichée
Le système SHALL afficher, dans la page d'une campagne clôturée dont tous les sondés ont soumis leurs réponses, une ligne d'état « Clôturée : tous les sondés ont répondu ». Cette ligne MUST faire partie du contenu de la page et ne pas disparaître d'elle-même.

#### Scenario: Campagne terminée par les réponses
- **WHEN** un manager ouvre une campagne clôturée dont tous les sondés ont soumis
- **THEN** la ligne « Clôturée : tous les sondés ont répondu » est affichée dans la page

#### Scenario: Clôture avec des sondés manquants
- **WHEN** un manager ouvre une campagne qu'il a clôturée alors qu'un sondé n'avait pas soumis
- **THEN** la ligne n'est pas affichée
