# Tasks

## 1. Skill

- [x] 1.1 Créer `.claude/skills/saumon-deploy/SKILL.md` : frontmatter (`name: saumon-deploy`, `description` en français, `disable-model-invocation: true`) et introduction (une confirmation avant le déploiement, français, `AskUserQuestion`, rappel que les vérifications de code relèvent de `/saumon-finish`, aucune valeur propre à la production dans le fichier) ; vérifier que le dossier est listé par `ls .claude/skills` et que le frontmatter a la même forme que celui de `saumon-finish`.
- [x] 1.2 Rédiger l'étape « État des lieux » : `git fetch`, branche courante, `git status --short`, hash court et titre du `HEAD`, présence du `HEAD` sur `origin/<branche>` ou absence d'amont ; arrêt sur arbre sale avec la liste des fichiers, sans stash ni commit ; vérifier que chaque cas (arbre propre, sale, `HEAD` poussé, non poussé, sans amont) est décrit avec sa conséquence.
- [x] 1.3 Rédiger l'étape « Prérequis » : présence de `config/deploy.production.yml`, `.kamal/secrets.production` et `config/credentials/production.key`, `docker info`, et lecture de `bin/kamal secrets print -d production` à travers un filtre qui ne garde que le nom et la longueur de `RAILS_MASTER_KEY` et `SMTP_PASSWORD` ; vérifier dans ce dépôt, en exécutant la commande filtrée décrite, que deux noms avec une longueur non nulle s'affichent et qu'aucune valeur n'apparaît dans la sortie.
- [x] 1.4 Rédiger l'étape « Ce qui va partir » : `bin/kamal app version -d production`, comparaison avec `HEAD` (déjà déployé, ancêtre avec `git log --oneline <version>..HEAD`, absent ou non ancêtre, illisible) ; vérifier que chaque cas a sa formulation et qu'aucun ne produit une liste inventée.
- [x] 1.4a Vérifier sur le dépôt réel que `bin/kamal app version -d production` renvoie un hash que `git cat-file -t` reconnaît, ou documenter la forme réelle de la sortie dans le skill si elle contient autre chose que le hash seul.
- [x] 1.5 Rédiger la confirmation unique : `AskUserQuestion` dont la question contient la commande exacte `bin/kamal deploy -d production`, la branche, le `HEAD`, l'état poussé ou non et la liste des commits, avec les choix *Oui, déployer* et *Non* ; vérifier que le « non » termine sans exécuter de commande Kamal et qu'aucune option n'est ajoutée à la commande.
- [x] 1.6 Rédiger l'étape « Déploiement » : `export PATH=/usr/local/rvm/rubies/ruby-3.4.6/bin:$PATH`, délai de commande large, aucune interruption du build ; vérifier que la commande décrite est strictement `bin/kamal deploy -d production`.
- [x] 1.7 Rédiger l'étape « Contrôle » : `APP_HOST` lu dans `config/deploy.production.yml`, `curl` sur `https://<APP_HOST>/up` attendant `200`, `bin/kamal app version -d production` égal au hash du `HEAD`, `bin/kamal details -d production` ; vérifier le comportement quand `APP_HOST` est introuvable (contrôle de version seul, signalé).
- [x] 1.8 Rédiger l'étape « Échec » : cas du déploiement qui échoue avant la bascule (logs du dernier conteneur créé via `bin/kamal server exec -d production` avec `docker logs`, puisque `bin/kamal app logs` ne lit que les conteneurs en service ; ancienne version toujours en service, confirmée par `app version`, aucun rollback proposé) et cas du déploiement réussi mais contrôle en échec (logs puis `bin/kamal rollback <version précédente> -d production` dans une question séparée, absente si la version précédente est inconnue) ; vérifier qu'aucune écriture sur le serveur n'est possible sans le « oui » correspondant.
- [x] 1.9 Rédiger le résumé final : branche et commit déployés, version précédente, contrôle de santé, rollback fait ou non ; vérifier qu'il couvre chaque issue (refus, succès, échec avant bascule, échec après déploiement).

## 2. Documentation

- [x] 2.1 Mentionner `/saumon-deploy` dans `.claude/skills/project-conventions/SKILL.md` (à côté de `/saumon-finish` et `/saumon-dependabot`) ; vérifier par `grep -n saumon-deploy .claude/skills/project-conventions/SKILL.md`.
- [x] 2.2 Mettre à jour le README : une phrase dans la liste de `.claude/` de la section *Développé en SDD avec OpenSpec*, et une phrase dans la section *Déploiement* indiquant que `/saumon-deploy` exécute `bin/kamal deploy -d production` après confirmation ; ne pas toucher au sommaire ni aux badges ; vérifier par `grep -n saumon-deploy README.md`.

## 3. Vérification d'ensemble

- [x] 3.1 Relire le skill de bout en bout face à `design.md` (chaque décision y apparaît) et au dépôt réel (présence des fichiers de production, sous-commandes Kamal utilisées) ; vérifier qu'aucune IP, aucun domaine ni chemin de secret ne figure dans `SKILL.md` avec `grep -nE "192\.168|saumon\.cc|smtp_password|ovh" .claude/skills/saumon-deploy/SKILL.md` (aucune ligne attendue).
- [ ] 3.2 Essai à blanc sans déployer : lancer `/saumon-deploy` et vérifier l'état des lieux, les prérequis et l'écran de confirmation (commits listés, branche affichée), puis répondre « non » ; vérifier que `bin/kamal app version -d production` renvoie toujours la même version qu'avant l'essai.

## Workflow follow-up

- Archiver le changement après l'essai à blanc.
- Un vrai déploiement avec `/saumon-deploy` valide ensuite le parcours complet (contrôle de santé et, si besoin, le chemin d'échec).
