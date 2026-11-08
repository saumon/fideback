# Spec Delta

## ADDED Requirements

### Requirement: Message Telegram à la clôture automatique
Le système SHALL envoyer au manager, en plus de l'e-mail de clôture automatique et lorsque ses notifications Telegram sont activées, un message Telegram qui annonce que tous ses sondés ont répondu, nomme la campagne, donne le nombre de réponses et contient un lien vers la campagne. Ce message MUST partir une seule fois par campagne.

#### Scenario: Envoi à la clôture
- **WHEN** la soumission du dernier sondé clôture la campagne « Entretiens 2026 » d'un manager dont Telegram est activé
- **THEN** il reçoit l'e-mail de clôture et un message Telegram qui nomme « Entretiens 2026 », donne le nombre de réponses et contient le lien vers la campagne

#### Scenario: Telegram désactivé
- **WHEN** la campagne d'un manager dont Telegram est désactivé ou non configuré se clôture automatiquement
- **THEN** il reçoit seulement l'e-mail de clôture

#### Scenario: Envoi unique
- **WHEN** deux soumissions simultanées clôturent la même campagne
- **THEN** le manager ne reçoit qu'un seul message Telegram

#### Scenario: Aucun message sans clôture automatique
- **WHEN** un manager clôture lui-même sa campagne
- **THEN** aucun message Telegram de clôture n'est envoyé

#### Scenario: Échec Telegram
- **WHEN** l'envoi du message Telegram échoue
- **THEN** la campagne reste clôturée, les réponses restent soumises et l'e-mail de clôture est envoyé
