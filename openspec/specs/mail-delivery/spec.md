# mail-delivery Specification

## Purpose

Permettre de configurer, par déploiement et sans modifier l'application, l'envoi des e-mails (serveur SMTP, expéditeur, adresse publique des liens) afin que les e-mails d'activation, de réinitialisation et d'invitation arrivent à leurs destinataires.

## Requirements

### Requirement: Envoi par un serveur SMTP configurable
Le système SHALL envoyer ses e-mails par un serveur SMTP dont l'adresse, le port, l'identifiant et le mot de passe sont fournis par la configuration du déploiement. Une configuration incomplète SHALL être traitée comme une absence de configuration.

#### Scenario: Configuration complète
- **WHEN** l'adresse, le port, l'identifiant et le mot de passe SMTP sont tous renseignés
- **THEN** les e-mails sont envoyés par ce serveur

#### Scenario: Configuration partielle
- **WHEN** au moins l'un de ces quatre réglages est absent
- **THEN** le système se comporte comme si SMTP n'était pas configuré

#### Scenario: Envoi désactivé explicitement
- **WHEN** l'envoi SMTP est désactivé par réglage alors que la configuration est complète
- **THEN** aucun e-mail n'est envoyé par ce serveur

### Requirement: Signalement d'un SMTP absent en production
Le système SHALL signaler au démarrage, en production, que SMTP n'est pas configuré ou est désactivé, car aucun compte ne peut alors être activé.

#### Scenario: Démarrage sans SMTP
- **WHEN** l'application démarre en production sans configuration SMTP exploitable
- **THEN** un avertissement indiquant si SMTP est non configuré ou désactivé est écrit dans le journal

### Requirement: Boîte mail de développement conservée
Le système SHALL, hors production et sans configuration SMTP complète, intercepter les e-mails dans la boîte mail de développement au lieu de les envoyer.

#### Scenario: Développement sans SMTP
- **WHEN** l'application tourne en développement sans configuration SMTP complète
- **THEN** les e-mails sont consultables dans la boîte mail de développement et aucun n'est envoyé

### Requirement: Expéditeur unique
Le système SHALL utiliser la même adresse d'expéditeur pour tous ses e-mails, configurable par le déploiement.

#### Scenario: E-mails de nature différente
- **WHEN** l'application envoie un e-mail d'activation, de réinitialisation de mot de passe et une invitation
- **THEN** les trois portent la même adresse d'expéditeur

### Requirement: Adresse publique des liens
Le système SHALL construire les liens des e-mails à partir de l'hôte, du port et du protocole configurés par le déploiement.

#### Scenario: Hôte et protocole configurés
- **WHEN** l'hôte public et le protocole sont configurés
- **THEN** les liens des e-mails pointent vers cette adresse
