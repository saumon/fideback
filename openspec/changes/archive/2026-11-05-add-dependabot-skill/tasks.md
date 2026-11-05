# Tasks

## 1. Skill

- [x] 1.1 Créer `.claude/skills/saumon-dependabot/SKILL.md` : frontmatter (`name`, `description` en français, `disable-model-invocation: true`) et introduction (confirmation avant chaque écriture, français, `AskUserQuestion`) ; vérifier que le fichier est listé par `ls .claude/skills` et que le frontmatter est valide (même forme que `saumon-finish`).
- [x] 1.2 Rédiger l'étape « État des lieux » : `git fetch --prune`, branche courante `dev`, arbre propre, `git pull --ff-only` ; vérifier que chaque cas d'arrêt (arbre sale, autre branche, `dev` en retard) y est décrit avec sa sortie.
- [x] 1.3 Rédiger l'étape « Liste et choix » : tri `committerdate` croissant, repérage des branches `github_actions`, cas aucune branche, `AskUserQuestion` ; vérifier en exécutant la commande décrite dans ce dépôt (`origin/dependabot/bundler/image_processing-2.2.0` en premier, `selenium-webdriver-4.52.0` ensuite).
- [x] 1.4 Rédiger l'étape « Rebase » : branche locale depuis `origin/<branche>`, `git rebase origin/dev`, gestion du conflit (abort, retour sur `dev`, nettoyage) et du cas « déjà à jour » ; vérifier que chaque sortie anticipée laisse le dépôt sur `dev`, propre.
- [x] 1.5 Rédiger l'étape « Vérifications » : `PATH` Ruby, les quatre commandes dans l'ordre de `saumon-finish`, règle de refus en cas d'échec avec nettoyage ; vérifier que le texte est aligné sur celui de `saumon-finish`.
- [x] 1.6 Rédiger les trois confirmations séparées (push `--force-with-lease`, merge `--no-ff` + push `dev`, suppression de la branche distante) avec les commandes exactes dans la question, le refus de `--force` nu et la gestion du rejet du lease ; vérifier qu'aucune écriture distante n'est possible avant le « oui » correspondant.
- [x] 1.7 Rédiger le résumé final (branche, vérifications, push forcé fait ou non, merge, suppression) ; vérifier qu'il couvre chaque issue possible.

## 2. Documentation et vérification

- [x] 2.1 Mentionner `/saumon-dependabot` dans `.claude/skills/project-conventions/SKILL.md` (à côté de `/saumon-finish`) et, si la section *Contribuer* du README décrit les skills, y ajouter une ligne ; vérifier par `grep -rn saumon-dependabot .claude README.md`.
- [x] 2.2 Relire le skill de bout en bout face à ce design et au dépôt réel (`git for-each-ref` sur `origin`, présence de `bin/ci`) ; vérifier que chaque décision du design y apparaît.
- [x] 2.3 Essai à blanc (sans confirmer d'écriture distante) : lancer `/saumon-dependabot`, choisir une branche, constater la liste, le rebase et les vérifications, puis répondre « non » aux trois confirmations ; vérifier que `git status` est propre, que la branche courante est `dev` et que `git ls-remote origin` est inchangé.

## Workflow follow-up

- Archiver le changement après l'essai à blanc.
