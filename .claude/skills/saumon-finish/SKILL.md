---
name: saumon-finish
description: Termine une session de travail sur Fideback : vérifie si le README est à jour, lance les vérifications (tests, RuboCop, tests système, bin/ci), committe tous les fichiers modifiés en conventional commit en anglais après validation du message, puis propose le push. À invoquer explicitement avec /saumon-finish.
disable-model-invocation: true
---

Termine le travail en cours : README, vérifications, commit, push. Chaque étape qui écrit (modification du README, commit, push) attend une confirmation explicite de l'utilisateur. Réponds en français ; le message de commit est en anglais.

Pour toutes les questions à l'utilisateur, utilise `AskUserQuestion`.

## 1. État des lieux

Lance `git status --short` et `git branch --show-current`.

- Si l'arbre est propre, dis-le et arrête-toi : il n'y a rien à committer.
- Sinon, garde en tête la liste des fichiers modifiés et non suivis, elle sert aux étapes suivantes.

## 2. README

Demande : « Faut-il vérifier que le README est à jour ? » (oui / non).

Si non, passe à l'étape 3.

Si oui :
1. Lis `README.md`, `docs/fonctionnement.md` et le diff (`git diff HEAD` et les fichiers non suivis).
2. Vérifie chaque affirmation touchée par le diff, et cherche ce que le diff introduit sans que le README en parle. Contrôle les faits dans le code (versions, routes, noms de fichiers, variables) au lieu de supposer.
3. Si tout est exact, dis-le brièvement.
4. Sinon, liste les écarts et les modifications proposées, puis demande confirmation avant d'écrire. Applique uniquement ce qui est accepté. Les fichiers modifiés seront inclus dans le commit.

### Où écrire quoi

Le README est la vitrine du projet sur GitHub : il reste court, professionnel et à jour. Le détail vit ailleurs.

| Le diff introduit… | À mettre à jour |
|---|---|
| un comportement visible (écran, règle métier, réglage admin) | `docs/fonctionnement.md` : un paragraphe par fonctionnalité, dans le même style (gras sur les termes clés, routes et réglages en code). Dans le README, seule la liste *Fonctionnalités* change, en une ligne, si une capacité nouvelle apparaît pour un rôle |
| une variable d'environnement ou un réglage SMTP | tableau de la section *Configuration* |
| une commande, un prérequis, un changement de version (Ruby, Rails) | *Démarrage rapide*, *Pile technique*, les badges de version de l'en-tête et `.ruby-version` en cohérence |
| une étape de vérification ou de CI | *Tests et qualité* |
| un point de déploiement ou de reprise (migration, volume, secret) | *Déploiement* |
| un nouveau dossier de premier niveau | *Structure du dépôt* |
| un changement du workflow OpenSpec ou des skills | *Développé en SDD avec OpenSpec* et *Contribuer* |

### Règles de rédaction

- Français, ton neutre et factuel, vouvoiement. Pas de formulation promotionnelle.
- Ne répète pas une information : le README renvoie vers `docs/fonctionnement.md` et vers `openspec/specs/` au lieu de les recopier. La source de vérité du comportement reste `openspec/specs/`.
- Ne grave pas de chiffres qui vieillissent (nombre de tests, de spécifications, de changements archivés).
- Garde la structure, l'ordre des sections et le sommaire. Si tu ajoutes ou renommes une section, mets le sommaire à jour.
- Badges : n'en ajoute ni n'en retire sans que l'utilisateur le demande, sauf pour refléter un changement réel (version de Ruby ou de Rails). N'invente jamais un badge dont tu ne peux pas vérifier la source (licence absente, workflow inexistant).
- Ne documente pas ce que le code dit déjà (noms de classes, détails d'implémentation) : seulement ce qu'un utilisateur, un administrateur ou un contributeur doit savoir.

## 3. Vérifications (bloquantes)

Lance, dans cet ordre :

```bash
bin/rails test
bin/rubocop
bin/rails test:system
bin/ci
```

Les tests système lancent Chrome headless et durent plus longtemps que les autres : laisse-leur le temps de finir (délai de la commande relevé) au lieu de les interrompre. `bin/ci` rejoue les tests et RuboCop, et ajoute les audits (gems, importmap), Brakeman et les seeds : ne saute aucune de ces quatre commandes parce qu'une précédente a déjà passé.

Si `ruby` est introuvable dans le `PATH`, retrouve l'installation Ruby de la machine (version de `.ruby-version`) et ajuste le `PATH` pour la commande ; si tu n'y arrives pas, arrête-toi et explique.

**Refus de committer.** Si l'une des quatre commandes échoue, y compris les tests système ou `bin/ci`, ou ne peut pas s'exécuter (Chrome absent, délai dépassé, commande interrompue), **arrête-toi** : montre la sortie utile (échecs, offenses, avertissements Brakeman, vulnérabilités) et refuse de passer aux étapes 4 à 7. Aucun fichier n'est stagé, aucun commit ni push n'est fait, même si l'utilisateur le demande en cours de route : seul un nouveau passage du skill avec les quatre commandes au vert permet de committer. Ne contourne pas l'échec, ne désactive aucun test ni aucune règle, ne relance pas en boucle un test instable pour obtenir un vert sans en parler. L'utilisateur corrige, ou te demande de le faire, puis relance le skill.

## 4. Fichiers à committer

Tous les fichiers modifiés sont committés, y compris les fichiers non suivis non ignorés. Avant de stager :

1. Liste les fichiers non suivis (`git status --short | grep '^??'`).
2. Signale explicitement tout fichier suspect : secrets ou identifiants (`.env*`, `*.key`, `*.pem`, `master.key`, `credentials`), artefacts ou dumps (`tmp/`, `log/`, `storage/`, `*.sqlite3`, `*.log`, archives), captures d'écran de tests, gros fichiers binaires.
3. S'il y a des fichiers suspects, demande lesquels exclure et ne les stage pas. S'il n'y en a pas, passe directement à la suite.

Stage ensuite tout le reste (`git add -A`, en retirant avec `git restore --staged` ce que l'utilisateur a exclu) puis montre `git status --short`.

## 5. Message de commit

Rédige **un seul** commit couvrant tout le diff stagé, en lisant `git diff --cached` (pas seulement les noms de fichiers), et en t'alignant sur le style de `git log --oneline -10`.

Format conventional commit, en anglais :

```
<type>(<scope optionnel>): <description>

<corps optionnel>
```

- `type` parmi `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`. Choisis celui qui décrit l'effet principal du diff.
- Description à l'impératif, en minuscules, sans point final, 72 caractères au maximum.
- Corps seulement s'il apporte le pourquoi ou un détail non évident, lignes de 72 caractères au maximum.
- Changement incompatible : `!` après le type/scope et un pied `BREAKING CHANGE:`.
- Aucune ligne d'attribution (`Co-Authored-By`, « Generated with », etc.).

Si le diff mélange nettement plusieurs sujets sans rapport, signale-le en une phrase dans ta présentation, mais produis quand même un seul commit.

**Le message complet doit figurer dans la question elle-même.** La boîte de dialogue de `AskUserQuestion` peut s'afficher seule, sans le texte écrit avant l'appel : un message affiché uniquement en texte normal risque de ne jamais être vu. Dans le champ `question`, écris donc le message de commit intégral (titre, corps) suivi de « Ce message de commit convient-il ? ». Mets-le aussi en `preview` de l'option *Oui, committer*.

Les choix sont : *Oui, committer*, *Modifier* (l'utilisateur précise les changements, tu corriges et tu reposes la question avec la nouvelle version complète), *Annuler* (ne committe rien et laisse les fichiers stagés tels quels).

Ne committe qu'après un « oui » explicite sur la dernière version posée. Une réponse vide, « sans préférence » ou ambiguë n'est pas un « oui » : explique-le et reposte la question.

## 6. Commit

Commite avec le message validé, transmis tel quel (heredoc ou `-F`). N'utilise pas `--no-verify` et ne fais pas de `--amend`.

Si un hook échoue, montre l'erreur, ne contourne rien, et arrête-toi : le commit n'a pas eu lieu.

Affiche ensuite `git log --oneline -1`.

## 7. Push

Avant de poser la question, lance `git log --oneline @{u}..HEAD` (sans amont, `git log --oneline` limité aux derniers commits) pour connaître les commits réellement non poussés. N'annonce jamais un nombre ou une liste de commits que cette commande ne montre pas.

Demande : « Pousser maintenant ? » en indiquant la branche courante et la liste exacte des commits non poussés. Comme pour le message de commit, cette information doit figurer dans la question elle-même.

- Pas de `--force`, jamais.
- Si la branche est `main` (ou `master`), avertis clairement que le push va directement sur la branche principale, et demande une confirmation explicite en le précisant dans la question.
- Si la branche n'a pas d'amont (`git rev-parse --abbrev-ref @{u}` échoue), propose `git push -u origin <branche>`.
- Sinon, `git push`.

Si l'utilisateur refuse, termine sans pousser. En cas d'échec du push (branche en retard, droits), affiche l'erreur et ne tente rien d'autre sans accord.

## 8. Résumé

Termine par un résumé court : README (vérifié / modifié / ignoré), vérifications (tests, RuboCop, tests système et `bin/ci` passés), hash et titre du commit, push (fait / non fait).
