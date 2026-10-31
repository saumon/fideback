# Spec Delta

## Purpose

Ajouter à la connexion d'un manager un second geste, le clic sur un lien à usage unique reçu par e-mail, que l'Admin impose à tous les comptes en l'activant dans la danger zone.

## ADDED Requirements

### Requirement: Lien de connexion envoyé après le mot de passe
Lorsque la connexion par lien unique est activée, le système SHALL, après un e-mail et un mot de passe corrects d'un compte activé, envoyer à cette adresse un e-mail contenant un lien de connexion personnel, et afficher l'écran « Consultez votre boîte mail » à la place de la liste des campagnes.

#### Scenario: Mot de passe correct
- **WHEN** un manager au compte activé soumet son e-mail et son mot de passe corrects alors que l'option est activée
- **THEN** un e-mail de lien de connexion lui est envoyé et l'écran « Consultez votre boîte mail » s'affiche avec son adresse

#### Scenario: Option désactivée
- **WHEN** un manager soumet ses identifiants corrects alors que l'option est désactivée
- **THEN** il est connecté sans lien et redirigé vers la liste de ses campagnes

### Requirement: Aucune session avant le clic
Lorsque la connexion par lien unique est activée, le système SHALL n'ouvrir aucune session tant que le lien n'a pas été suivi. Les pages de gestion SHALL rester refusées à la personne qui a saisi son mot de passe.

#### Scenario: Accès avant le clic
- **WHEN** un manager a saisi son mot de passe mais n'a pas suivi le lien, puis demande la liste des campagnes
- **THEN** il est redirigé vers la page de connexion

#### Scenario: Ouverture de la session
- **WHEN** un visiteur suit un lien de connexion valable
- **THEN** la session du manager concerné est ouverte, il est redirigé vers la liste de ses campagnes et un message confirme la connexion

### Requirement: Validité et usage unique du lien
Le système SHALL accepter un lien de connexion pendant 10 minutes après son envoi et une seule fois. Un nouvel envoi pour le même compte SHALL invalider les liens précédents. Le lien SHALL fonctionner depuis n'importe quel navigateur ou appareil.

#### Scenario: Lien déjà utilisé
- **WHEN** un visiteur suit un lien de connexion déjà utilisé
- **THEN** aucune session n'est ouverte et la page de lien refusé s'affiche

#### Scenario: Lien expiré
- **WHEN** un visiteur suit un lien envoyé il y a plus de 10 minutes
- **THEN** aucune session n'est ouverte et la page de lien refusé s'affiche

#### Scenario: Lien remplacé
- **WHEN** un second lien est envoyé au même compte puis qu'un visiteur suit le premier
- **THEN** aucune session n'est ouverte et la page de lien refusé s'affiche

#### Scenario: Autre appareil
- **WHEN** un manager saisit son mot de passe sur un ordinateur et suit le lien reçu depuis un téléphone
- **THEN** la session est ouverte sur le téléphone

### Requirement: Écran d'attente et renvoi du lien
L'écran « Consultez votre boîte mail » SHALL proposer de renvoyer le lien et de changer d'adresse. Le système SHALL envoyer au plus un lien par minute et par compte, que la demande vienne d'une nouvelle connexion ou du bouton de renvoi.

#### Scenario: Renvoi après une minute
- **WHEN** un manager demande un nouveau lien plus d'une minute après le dernier envoi
- **THEN** un nouvel e-mail est envoyé, l'ancien lien cesse de fonctionner et un message confirme l'envoi

#### Scenario: Renvoi trop rapproché
- **WHEN** un manager demande un nouveau lien moins d'une minute après le dernier envoi
- **THEN** aucun e-mail n'est envoyé et un message lui demande de patienter

#### Scenario: Changer d'adresse
- **WHEN** un manager choisit de changer d'adresse depuis l'écran d'attente
- **THEN** il revient au formulaire de connexion et la demande de renvoi n'est plus possible sans nouveau mot de passe

### Requirement: Lien de connexion refusé
Le système SHALL afficher, pour un lien expiré, déjà utilisé, remplacé ou inconnu, une même page explicative qui propose de recommencer la connexion, sans révéler lequel des cas s'applique.

#### Scenario: Page de lien refusé
- **WHEN** un visiteur suit un lien qui n'est plus valable
- **THEN** une page indique que le lien n'est plus valable et propose de se reconnecter, avec le statut d'une page introuvable

#### Scenario: Manager déjà connecté
- **WHEN** un manager déjà connecté suit un lien de connexion
- **THEN** il est redirigé vers ses campagnes avec le message habituel de session déjà ouverte et le lien n'est pas consommé

### Requirement: Comptes et saisies sans lien
Le système SHALL n'envoyer aucun lien de connexion pour un mot de passe incorrect, une adresse inconnue ou un compte non activé, et SHALL conserver pour ces cas les messages de connexion existants.

#### Scenario: Mot de passe incorrect
- **WHEN** quelqu'un soumet un mot de passe incorrect alors que l'option est activée
- **THEN** aucun e-mail n'est envoyé et le message d'erreur générique des identifiants invalides s'affiche

#### Scenario: Compte non activé
- **WHEN** un manager au compte non activé soumet ses identifiants corrects alors que l'option est activée
- **THEN** aucun lien n'est envoyé et le message d'activation habituel s'affiche

### Requirement: E-mail du lien de connexion
Le système SHALL envoyer le lien dans un e-mail à l'habillage commun, avec une version texte, qui salue le manager par son nom, porte un bouton de connexion, rappelle les 10 minutes de validité et l'usage unique, et invite à ignorer le message en cas de demande inconnue.

#### Scenario: Contenu de l'e-mail
- **WHEN** un lien de connexion est envoyé
- **THEN** l'e-mail est adressé au manager, salue son nom, contient le lien personnel dans ses versions HTML et texte et indique qu'il est valable 10 minutes

### Requirement: « Se souvenir de moi » indisponible
Tant que la connexion par lien unique est activée, le système SHALL masquer l'option « Se souvenir de moi » sur le formulaire de connexion et SHALL ignorer les cookies de session persistante déjà émis.

#### Scenario: Formulaire de connexion
- **WHEN** un visiteur ouvre la page de connexion alors que l'option est activée
- **THEN** la case « Se souvenir de moi » n'est pas affichée

#### Scenario: Cookie déjà émis
- **WHEN** un visiteur sans session présente un cookie « se souvenir de moi » valide alors que l'option est activée
- **THEN** il n'est pas connecté et est redirigé vers la page de connexion

### Requirement: Sessions ouvertes conservées
Le système SHALL laisser valables les sessions déjà ouvertes quand la connexion par lien unique est activée ou désactivée.

#### Scenario: Activation avec une session ouverte
- **WHEN** un manager est connecté et l'Admin active l'option
- **THEN** ce manager reste connecté jusqu'à sa déconnexion ou l'expiration normale de sa session
