---
name: saumon-finish
description: Termine une session de travail sur Fideback : vérifie si le README est à jour, lance les vérifications (tests, RuboCop), committe tous les fichiers modifiés en conventional commit en anglais après validation du message, puis propose le push. À invoquer explicitement avec /saumon-finish.
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
1. Lis `README.md` et le diff (`git diff HEAD` et les fichiers non suivis).
2. Vérifie chaque affirmation du README touchée par le diff, et cherche ce que le diff introduit sans que le README en parle (commandes, variables d'environnement, fonctionnement, prérequis, déploiement). Contrôle les faits dans le code (versions, routes, noms de fichiers) au lieu de supposer.
3. Si tout est exact, dis-le brièvement.
4. Sinon, liste les écarts et les modifications proposées, puis demande confirmation avant d'écrire. Applique uniquement ce qui est accepté. Le README modifié sera inclus dans le commit.

## 3. Vérifications (bloquantes)

Lance, dans cet ordre :

```bash
bin/rails test
bin/rubocop
```

Si `ruby` est introuvable dans le `PATH`, retrouve l'installation Ruby de la machine (version de `.ruby-version`) et ajuste le `PATH` pour la commande ; si tu n'y arrives pas, arrête-toi et explique.

Si l'une des commandes échoue, **arrête-toi** : montre la sortie utile (échecs, offenses) et ne committe rien. Ne contourne pas l'échec, ne désactive aucun test ni aucune règle. L'utilisateur corrige, ou te demande de le faire, puis relance le skill.

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

Termine par un résumé court : README (vérifié / modifié / ignoré), vérifications (passées), hash et titre du commit, push (fait / non fait).
