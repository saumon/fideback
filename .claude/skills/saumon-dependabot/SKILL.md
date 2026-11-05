---
name: saumon-dependabot
description: Intègre une branche Dependabot dans dev sur Fideback : liste les branches origin/dependabot/* de la plus ancienne à la plus récente, rebase la branche choisie sur origin/dev, lance les vérifications (tests, RuboCop, tests système, bin/ci), puis propose le push forcé de la branche, le merge --no-ff dans dev avec push, et la suppression de la branche distante. À invoquer explicitement avec /saumon-dependabot.
disable-model-invocation: true
---

Intègre une branche Dependabot dans `dev` : choix, rebase, vérifications, push forcé de la branche, merge. Chaque écriture distante (push forcé, merge poussé, suppression de branche) attend une confirmation explicite de l'utilisateur, une question par écriture. Réponds en français.

Pour toutes les questions à l'utilisateur, utilise `AskUserQuestion`.

Règles valables pour tout le skill :
- Pas de `--force` nu, jamais : seul `--force-with-lease` est autorisé, et seulement sur une branche `dependabot/*`.
- Aucun `stash`, aucun changement de branche à la place de l'utilisateur au départ.
- Aucune écriture distante avant que les quatre vérifications soient vertes sur la branche rebasée.
- Aucun message de commit ne contient de ligne d'attribution.

## 1. État des lieux

Lance `git fetch --prune`, puis `git branch --show-current` et `git status --short`.

Arrête-toi, en expliquant pourquoi et sans rien modifier, si :
- la branche courante n'est pas `dev` ;
- l'arbre n'est pas propre (fichiers modifiés ou non suivis) ;
- `git pull --ff-only` échoue (`dev` a divergé de `origin/dev`).

Sinon `dev` est à jour avec `origin/dev` : continue.

## 2. Liste et choix

Liste les branches avec :

```bash
git for-each-ref --sort=committerdate --format='%(committerdate:short) %(refname:short)' refs/remotes/origin/dependabot
```

Le tri est chronologique, la plus ancienne d'abord. Retire le préfixe `origin/` à l'affichage.

- Aucune branche : dis-le et arrête-toi.
- Signale, avant de demander, les branches dont le nom contient `github_actions` : `bin/ci` n'exerce pas les workflows, donc les vérifications ne valident pas ce type de mise à jour.
- Demande laquelle intégrer avec `AskUserQuestion`, en indiquant la date et le nom complet. S'il y a plus de quatre branches, propose les plus anciennes (« Autre » permet de saisir les suivantes).

## 3. Rebase

Pour la branche choisie `<branche>` (par exemple `dependabot/bundler/selenium-webdriver-4.52.0`) :

```bash
git switch -c <branche> origin/<branche>
git rebase origin/dev
```

- **Conflit** : `git rebase --abort`, `git switch dev`, `git branch -D <branche>`, explique les fichiers en conflit et arrête-toi. Aucune écriture distante.
- **Déjà à jour** (`origin/dev` est déjà un ancêtre de la branche, le rebase ne change rien) : note-le, l'étape 5 (push forcé) sera sautée.
- Rien n'est poussé à ce stade.

## 4. Vérifications (bloquantes)

Commence par installer les gems de la branche (une mise à jour de dépendance change le `Gemfile.lock`, et la gem peut manquer localement) :

```bash
bundle install
```

Si `bundle install` échoue, traite-le comme un échec de vérification (voir « Refus de continuer »). Il ne doit modifier aucun fichier suivi : vérifie avec `git status --short` ; sinon, arrête-toi et explique.

Lance ensuite, dans cet ordre, sur la branche rebasée :

```bash
bin/rails test
bin/rubocop
bin/rails test:system
bin/ci
```

Si `ruby` est introuvable dans le `PATH`, utilise `export PATH=/usr/local/rvm/rubies/ruby-3.4.6/bin:$PATH` ; si tu n'y arrives pas, arrête-toi et explique.

Les tests système lancent Chrome headless et durent plus longtemps : laisse-leur le temps de finir (délai de la commande relevé) au lieu de les interrompre. `bin/ci` rejoue les tests et RuboCop, et ajoute les audits, Brakeman et les seeds : ne saute aucune des quatre commandes parce qu'une précédente a déjà passé.

**Refus de continuer.** Si l'une des commandes échoue ou ne peut pas s'exécuter, arrête-toi : montre la sortie utile, puis nettoie (`git switch dev`, `git branch -D <branche>`) et refuse les étapes 5 à 7, même si l'utilisateur le demande en cours de route. Ne contourne pas l'échec, ne désactive aucun test ni aucune règle, ne relance pas en boucle un test instable sans en parler. Un nouveau passage du skill est nécessaire.

## 5. Push forcé de la branche

Saute cette étape si la branche était déjà à jour (étape 3).

Dependabot rebase souvent sa branche après un merge dans `dev`. Juste avant de poser la question, lance `git fetch origin` puis compare `git rev-parse origin/<branche>` au commit de départ de l'étape 3 : si la branche distante a changé, arrête-toi (le lease échouerait) et propose de relancer le skill, avec le nettoyage de l'étape 4.

Lance ensuite `git log --oneline origin/dev..<branche>` pour connaître les commits de la branche. Demande : « Pousser la branche rebasée avec `git push --force-with-lease origin <branche>` ? » en listant ces commits. Cette information doit figurer dans la question elle-même.

- Si oui : `git push --force-with-lease origin <branche>`.
- Si le push est rejeté (le lease a échoué : Dependabot a probablement réécrit la branche), **le skill s'arrête là** : affiche l'erreur, explique-le, ne réessaie pas, **ne pose pas la question de l'étape 6**, nettoie comme à l'étape 4 (`git switch dev`, `git branch -D <branche>`) et propose de relancer le skill (nouveau `fetch`).
- Si non : nettoie (`git switch dev`, `git branch -D <branche>`) et termine par le résumé, sans merge.

## 6. Merge dans dev

Demande : « Merger `<branche>` dans `dev` (`git merge --no-ff`, message par défaut de git) puis pousser `dev` avec `git push origin dev` ? » Cette question vient après le push forcé et demande son propre « oui » : l'accord de l'étape 5 ne vaut pas pour le merge.

- Si oui : `git switch dev`, `git merge --no-ff <branche>` (message par défaut, sans modification), puis `git push origin dev`. Pas de `--force`.
- Si le push de `dev` échoue (branche en retard, droits), affiche l'erreur sans autre tentative et précise que le merge local est en place.
- Si non : `git switch dev`, `git branch -D <branche>` et termine sans merger.

Affiche ensuite `git log --oneline -3`.

## 7. Nettoyage

Une fois mergée, supprime la branche locale : `git branch -d <branche>`.

Lance `git fetch --prune` : GitHub supprime parfois la branche tout seul quand il détecte la PR comme fusionnée. Si `origin/<branche>` n'existe plus, dis-le et ne pose pas la question.

Sinon, demande : « Supprimer la branche distante avec `git push origin --delete <branche>` ? ». Question séparée, son propre « oui ». Si non, laisse-la. Si la suppression échoue avec « remote ref does not exist », GitHub l'a supprimée entre-temps : ce n'est pas une erreur, signale-le.

## 8. Résumé

Termine par un résumé court : branche choisie, rebase (fait, conflit, ou déjà à jour), vérifications (`bundle install`, tests, RuboCop, tests système et `bin/ci` passés), push forcé (fait, sauté ou refusé), merge et push de `dev` (hash et titre du commit de merge, fait ou non fait), branche distante (supprimée ou conservée).
