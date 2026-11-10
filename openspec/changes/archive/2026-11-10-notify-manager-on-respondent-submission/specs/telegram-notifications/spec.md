# Spec Delta

## ADDED Requirements

### Requirement: Notification Telegram à chaque réponse soumise
Le système SHALL envoyer au manager d'une campagne, sur Telegram, un message dès qu'un sondé soumet définitivement ses réponses, à condition que les notifications Telegram du manager soient activées. Le message MUST indiquer le nom du sondé et le nom de la campagne, et contenir un lien vers la page de la campagne.

#### Scenario: Notifications activées
- **WHEN** un sondé soumet ses réponses alors que le manager de la campagne a activé ses notifications Telegram
- **THEN** le manager reçoit un message Telegram qui nomme le sondé et la campagne, avec un lien vers la page de la campagne

#### Scenario: Notifications désactivées
- **WHEN** un sondé soumet ses réponses alors que le manager a désactivé ses notifications Telegram, ou ne les a pas configurées
- **THEN** aucun message Telegram n'est envoyé

#### Scenario: Soumission refusée
- **WHEN** un sondé tente de soumettre alors que des réponses manquent, ou que la campagne n'accepte plus de réponses
- **THEN** aucun message Telegram n'est envoyé

#### Scenario: Enregistrement sans soumettre
- **WHEN** un sondé enregistre sa progression sans soumettre
- **THEN** aucun message Telegram n'est envoyé

#### Scenario: Noms contenant des caractères spéciaux
- **WHEN** le nom du sondé ou de la campagne contient « <b> » ou « & »
- **THEN** ces caractères apparaissent tels quels dans Telegram, sans être interprétés comme de la mise en forme

#### Scenario: Dernier sondé
- **WHEN** la soumission est celle du dernier sondé et clôture la campagne
- **THEN** le manager reçoit d'abord le message annonçant la réponse du sondé, puis celui annonçant la clôture de la campagne

#### Scenario: Échec d'envoi
- **WHEN** Telegram refuse l'envoi ou ne répond pas
- **THEN** le sondé voit tout de même la confirmation de sa soumission, et l'échec reste silencieux pour le manager, comme pour les autres notifications Telegram

## MODIFIED Requirements

### Requirement: Envoi des notifications du manager sur Telegram
Le système SHALL envoyer sur Telegram chaque notification destinée au manager lorsque ses notifications Telegram sont activées, en plus de l'e-mail quand la notification en a un. Le message MUST reprendre l'essentiel de l'e-mail ou de l'événement, avec un lien vers la page concernée. Les e-mails d'authentification et ceux adressés à d'autres personnes MUST NOT être envoyés sur Telegram.

#### Scenario: Notifications activées
- **WHEN** une notification destinée au manager part alors que ses notifications Telegram sont activées
- **THEN** il reçoit un message Telegram, et l'e-mail si cette notification en a un

#### Scenario: Notifications désactivées
- **WHEN** une notification destinée au manager part alors que ses notifications Telegram sont désactivées
- **THEN** il reçoit seulement l'e-mail, s'il y en a un

#### Scenario: E-mails d'authentification
- **WHEN** un lien de connexion, un e-mail d'activation ou de réinitialisation du mot de passe est envoyé à un manager dont Telegram est activé
- **THEN** aucun message Telegram n'est envoyé

#### Scenario: Texte fourni par les utilisateurs
- **WHEN** le message reprend un nom de campagne contenant « <b> » ou « & »
- **THEN** ces caractères apparaissent tels quels dans Telegram, sans être interprétés comme de la mise en forme
