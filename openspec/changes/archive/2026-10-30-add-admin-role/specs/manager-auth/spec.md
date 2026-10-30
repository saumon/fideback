# Spec Delta

## ADDED Requirements

### Requirement: Premier compte créé administrateur
Le système SHALL attribuer le rôle `admin` au compte manager créé à l'inscription lorsqu'aucun manager n'existe encore, que son adresse e-mail soit activée ou non. Aucun autre compte SHALL recevoir ce rôle à l'inscription, y compris après la suppression de l'Admin.

#### Scenario: Première inscription
- **WHEN** un visiteur s'inscrit alors qu'aucun manager n'existe
- **THEN** le compte créé a le rôle `admin`

#### Scenario: Inscriptions suivantes
- **WHEN** un visiteur s'inscrit alors qu'au moins un manager existe
- **THEN** le compte créé a le rôle `manager`

#### Scenario: Admin supprimé
- **WHEN** l'Admin supprime son compte alors que d'autres managers existent, puis un visiteur s'inscrit
- **THEN** le nouveau compte a le rôle `manager` et plus aucun Admin n'existe

#### Scenario: Inscriptions simultanées
- **WHEN** deux visiteurs s'inscrivent au même moment alors qu'aucun manager n'existe
- **THEN** un seul des deux comptes reçoit le rôle `admin`

### Requirement: Comptes existants et premier administrateur
Le système SHALL, lors de l'introduction des rôles, attribuer le rôle `admin` au manager existant le plus ancien et le rôle `manager` à tous les autres.

#### Scenario: Base existante
- **WHEN** les rôles sont introduits alors que plusieurs managers existent
- **THEN** le manager créé en premier devient `admin` et les autres sont `manager`

#### Scenario: Base vide
- **WHEN** les rôles sont introduits alors qu'aucun manager n'existe
- **THEN** aucun Admin n'est créé et la prochaine inscription devient `admin`
