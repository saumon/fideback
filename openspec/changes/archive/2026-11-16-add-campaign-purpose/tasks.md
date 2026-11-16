# Tasks

## 1. Données et modèle

- [x] 1.1 Ajouter la migration `purpose` (text, nullable) sur `campaigns` et vérifier que `db/schema.rb` la reflète et que `bin/rails db:migrate` passe
- [x] 1.2 Valider `purpose` à 1000 caractères au plus, ajouter le libellé « Pourquoi cette campagne ? » dans `fr.yml`, et vérifier par des tests de modèle (vide, 1000, 1001, espaces seuls)

## 2. Formulaire de campagne

- [x] 2.1 Autoriser `purpose` dans `campaign_params` et ajouter un champ texte multiligne (`maxlength` 1000) après le nom dans `campaigns/_form`, puis vérifier par un test d'intégration la création et la modification d'un brouillon avec et sans motif, et le refus au-delà de 1000 caractères

## 3. Affichage au sondé

- [x] 3.1 Afficher le motif dans l'en-tête de `respondent_forms/show` seulement s'il est renseigné, avec échappement et retours à la ligne conservés, et vérifier par des tests (avec motif, sans motif, balises HTML échappées, campagne terminée)
- [x] 3.2 Rendre ce bloc cohérent avec le style existant de `respondent-intro` (coloré, animé) et le vérifier visuellement en lançant l'application

## 4. E-mail d'invitation

- [x] 4.1 Remplacer la phrase « prépare ses entretiens individuels » par une formulation neutre dans `invitation.html.erb` et `invitation.text.erb`, et vérifier par un test que l'e-mail ne contient plus « entretien »
- [x] 4.2 Ajouter le bloc « Pourquoi cette campagne ? » dans les deux versions, seulement si le motif est renseigné, et vérifier par des tests (avec motif, sans motif, espaces seuls)

## 5. Vérification d'ensemble

- [x] 5.1 Lancer la suite de tests complète et les vérifications avant fusion décrites dans le skill `project-conventions`, et vérifier qu'elles passent
