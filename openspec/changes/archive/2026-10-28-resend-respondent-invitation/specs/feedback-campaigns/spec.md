# Spec Delta

## ADDED Requirements

### Requirement: Renvoi d'une invitation
Le système SHALL permettre à un manager de renvoyer l'email d'invitation, avec le même lien personnel, à un sondé qui n'a pas encore soumis ses réponses, tant que la campagne est en cours et accepte des réponses.

#### Scenario: Renvoi nominal
- **WHEN** un manager renvoie l'invitation à un sondé n'ayant pas soumis, dans une campagne en cours dont la date limite n'est pas dépassée
- **THEN** l'email d'invitation est envoyé à ce sondé avec le même lien qu'à l'origine et la date de dernière invitation est mise à jour

#### Scenario: Sondé ayant déjà soumis
- **WHEN** un manager tente de renvoyer l'invitation à un sondé ayant soumis ses réponses
- **THEN** aucun email n'est envoyé, le renvoi est refusé et le bouton n'est pas proposé

#### Scenario: Campagne qui n'accepte plus de réponses
- **WHEN** un manager tente de renvoyer une invitation d'une campagne brouillon, clôturée ou dont la date limite est dépassée
- **THEN** aucun email n'est envoyé, le renvoi est refusé et le bouton n'est pas proposé

#### Scenario: Campagne d'un autre manager
- **WHEN** un manager tente de renvoyer une invitation pour un sondé d'une campagne appartenant à un autre manager
- **THEN** le système répond comme si le sondé n'existait pas

## MODIFIED Requirements

### Requirement: Cycle de vie de la campagne
Le système SHALL faire passer une campagne par les états brouillon, en cours puis clôturée, de façon irréversible vers l'avant.

#### Scenario: Lancement
- **WHEN** un manager lance une campagne brouillon valide
- **THEN** elle passe à l'état en cours, les invitations sont envoyées aux sondés et leur date d'invitation est enregistrée

#### Scenario: Clôture manuelle
- **WHEN** un manager clôture une campagne en cours
- **THEN** elle passe à l'état clôturée et les liens des sondés n'acceptent plus de réponse

#### Scenario: Date limite dépassée
- **WHEN** la date limite d'une campagne en cours est dépassée
- **THEN** les liens des sondés n'acceptent plus de nouvelle réponse

### Requirement: Suivi de l'avancement
Le système SHALL afficher au manager, pour chaque sondé d'une campagne en cours, s'il a répondu, partiellement répondu ou pas encore répondu, ainsi que la date de sa dernière invitation.

#### Scenario: Consultation du suivi
- **WHEN** un manager ouvre sa campagne en cours
- **THEN** il voit le statut de chaque sondé, la date de dernière invitation et le taux de réponse global

#### Scenario: Invitation datée après renvoi
- **WHEN** un manager renvoie l'invitation à un sondé
- **THEN** la date de dernière invitation affichée pour ce sondé est celle du renvoi
