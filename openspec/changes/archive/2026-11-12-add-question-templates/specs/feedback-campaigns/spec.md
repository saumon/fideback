# Spec Delta

## MODIFIED Requirements

### Requirement: Questionnaire de campagne
Le système SHALL associer à chaque campagne une liste ordonnée de questions, chacune comportant un commentaire texte libre et/ou une note de 1 à 5 (au moins l'un des deux), initialisée à la création à partir du modèle de questions choisi par le manager, le modèle par défaut étant présélectionné.

#### Scenario: Questions par défaut
- **WHEN** un manager commence une nouvelle campagne
- **THEN** le modèle par défaut est présélectionné et le formulaire est pré-rempli avec ses questions, modifiables avant le lancement

#### Scenario: Choix d'un autre modèle
- **WHEN** un manager sélectionne un autre modèle dans le formulaire de création
- **THEN** les questions du formulaire sont remplacées par celles du modèle, sans confirmation, sans recharger la page et sans perdre le nom, la date limite ni les contacts déjà saisis

#### Scenario: Modification après choix d'un modèle
- **WHEN** un manager a choisi un modèle puis ajoute, modifie ou supprime des questions avant d'enregistrer
- **THEN** la campagne est créée avec les questions du formulaire, sans changement du modèle

#### Scenario: Indépendance vis-à-vis du modèle
- **WHEN** un manager modifie ou supprime un modèle après avoir créé une campagne à partir de lui
- **THEN** les questions de la campagne restent celles qui ont été enregistrées

#### Scenario: Modification d'une campagne brouillon
- **WHEN** un manager ouvre le formulaire de modification d'une campagne brouillon
- **THEN** il voit les questions de la campagne et aucun sélecteur de modèle

#### Scenario: Modification après lancement
- **WHEN** un manager tente de modifier les questions, les managés ou les sondés d'une campagne lancée
- **THEN** la modification est refusée

#### Scenario: Question sans type de réponse
- **WHEN** un manager enregistre une question sans note ni commentaire
- **THEN** l'enregistrement est refusé
