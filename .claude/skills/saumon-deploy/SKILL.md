---
name: saumon-deploy
description: Déploie Fideback en production avec Kamal : contrôle l'état local (arbre propre, fichiers et secrets de production, Docker), montre la branche, le commit et les commits qui s'ajoutent à la version en production, demande une confirmation explicite, exécute bin/kamal deploy -d production, puis vérifie que l'application répond. À invoquer explicitement avec /saumon-deploy.
disable-model-invocation: true
---

Déploie l'application en production avec Kamal : état des lieux, prérequis, aperçu de ce qui part, confirmation, déploiement, contrôle. Le déploiement et le retour arrière éventuel attendent chacun une confirmation explicite de l'utilisateur. Réponds en français.

Pour toutes les questions à l'utilisateur, utilise `AskUserQuestion`.

Ce skill ne lance aucune vérification de code (tests, RuboCop, `bin/ci`) : c'est le rôle de `/saumon-finish`, à exécuter avant.

Règles valables pour tout le skill :
- Kamal déploie le **commit** (image tagguée par son hash), pas le répertoire de travail.
- Toutes les commandes Kamal visent la production avec `-d production`, et Ruby n'est pas dans le `PATH` : préfixe chaque commande Kamal par `export PATH=/usr/local/rvm/rubies/ruby-3.4.6/bin:$PATH`.
- Aucune écriture git : pas de `stash`, de commit, de push ni de changement de branche à la place de l'utilisateur.
- Aucun secret n'est jamais affiché ni lu directement. Ne lis aucun fichier de secrets ; n'exécute `bin/kamal secrets print -d production` que sous le filtre de l'étape 2, jamais seul.
- Ne lance que les commandes Kamal décrites ici : `secrets print` (filtré), `app version`, `deploy`, `details`, `server exec` pour lire des logs, et `rollback` après confirmation. N'ajoute aucune option à `deploy` (`--skip-push`, `--version`…), n'utilise jamais `setup`, `remove`, `app exec` ni `server exec` pour autre chose que `docker logs`.
- Aucune valeur propre à la production (adresse du serveur, domaine) n'est écrite dans ce fichier : le domaine se lit à l'exécution dans `config/deploy.production.yml`.

## 1. État des lieux

Lance `git fetch --quiet`, puis :

```bash
git branch --show-current            # vide : HEAD détachée
git status --short
git log -1 --format='%h %s'          # hash court et titre du HEAD
git rev-parse HEAD                   # hash complet
git branch -r --contains HEAD        # branches distantes qui contiennent HEAD
```

- **Arbre non propre** (fichiers modifiés ou non suivis) : arrête-toi, liste les fichiers, explique que Kamal déploie le commit et ignorerait ces changements (il n'affiche qu'un avertissement), et demande de les committer ou de les écarter. Ne stashe pas, ne committe pas à la place de l'utilisateur.
- **Arbre propre** : retiens la branche (ou « HEAD détachée »), le hash court et le titre.
- **Poussé** : `HEAD` est poussé si au moins une branche distante le contient ; retiens laquelle. Sinon, il est **non poussé** : retiens-le et, si la branche a un amont, la liste des commits en avance avec `git log --oneline @{u}..HEAD`. Un `HEAD` non poussé n'empêche pas de continuer : c'est signalé à l'étape 4, car la production ne serait pas retrouvable sur GitHub.
- Une branche sans amont, ou une HEAD détachée, ne bloque pas non plus : même signalement.

## 2. Prérequis

Vérifie, sans rien modifier, ces cinq points ; s'il en manque, arrête-toi en les nommant tous avec leur effet, sans tenter de les réparer :

| Point | Vérification | Effet s'il manque |
|---|---|---|
| `config/deploy.production.yml` | le fichier existe | Kamal viserait l'adresse d'exemple du modèle `deploy.yml` et échouerait |
| `.kamal/secrets.production` | le fichier existe | erreur `Secret 'RAILS_MASTER_KEY' not found` : avec `-d production`, Kamal ne lit pas `.kamal/secrets` |
| `config/credentials/production.key` | le fichier existe | les credentials de production restent indéchiffrables, le conteneur plante au démarrage (`InvalidMessage`) et le healthcheck échoue |
| Docker | `docker info >/dev/null 2>&1` réussit | le build est impossible ; si l'erreur est `permission denied`, la session n'a pas le groupe `docker` (relancer le serveur de terminal depuis une session fraîche) |
| Secrets résolus | la commande filtrée ci-dessous affiche les deux noms avec une longueur non nulle | un secret vide ou absent donnerait un conteneur qui démarre mal |

Commande filtrée pour les secrets, qui n'affiche que le nom et la longueur, jamais une valeur :

```bash
bin/kamal secrets print -d production 2>/dev/null | awk '{ i=index($0,"="); if (i>0) { n=substr($0,1,i-1); if (n=="RAILS_MASTER_KEY"||n=="SMTP_PASSWORD") print n, "longueur=" length($0)-i } }'
```

Attendu : `RAILS_MASTER_KEY longueur=<n>` et `SMTP_PASSWORD longueur=<n>`, avec `n` supérieur à 0. Une ligne absente ou à `longueur=0` est un manque.

## 3. Ce qui va partir

Relève la version actuellement en production. La sortie de `app version` mélange des lignes `INFO` et `App Host:` avec le hash : ne garde que la ligne qui est un hash.

```bash
bin/kamal app version -d production 2>/dev/null | grep -E '^[0-9a-f]{40}(_uncommitted_[0-9a-f]+)?$' | head -1
```

Compare cette version `<prod>` au `HEAD`, et retiens-la (elle sert à l'étape 7 pour un retour arrière) :

- **Aucune version lue** (serveur injoignable, aucun conteneur, premier déploiement) : dis-le, n'invente pas de liste, retiens « version inconnue ». Continue : si le serveur est réellement inaccessible, Kamal échouera lui-même à l'étape 5.
- **`<prod>` égale `HEAD`** : indique que cette version est déjà en production. L'étape 4 demandera s'il faut redéployer quand même (utile après un changement de variable d'environnement ou de secret).
- **`<prod>` avec le suffixe `_uncommitted_`, ou inconnue de git** (`git cat-file -e <prod>^{commit}` échoue) : signale que la version en production n'est pas dans l'historique local, ne produis pas de liste de commits.
- **`<prod>` n'est pas un ancêtre de `HEAD`** (`git merge-base --is-ancestor <prod> HEAD` échoue) : signale un retour en arrière ou une branche divergente, avec le nombre de commits de la production absents de `HEAD` (`git rev-list --count HEAD..<prod>`) et au plus dix d'entre eux (`git log --oneline -10 HEAD..<prod>`).
- **`<prod>` est un ancêtre de `HEAD`** : la liste des commits qui partent est `git log --oneline <prod>..HEAD`. Au-delà de vingt lignes, garde les vingt plus récentes et indique « et N autres ».

## 4. Confirmation

Pose **une** question avec `AskUserQuestion`. L'information décisive doit figurer dans la question elle-même : la boîte de dialogue peut s'afficher sans le texte écrit avant l'appel. La question contient :

- la branche (ou « HEAD détachée »), le hash court et le titre du `HEAD` ;
- l'état poussé : « poussé sur `<branche distante>` » ou **« non poussé »** en toutes lettres ;
- la version actuellement en production (hash court, ou « inconnue ») et, selon l'étape 3, la liste des commits qui partent, ou la mention « déjà en production » ou « retour en arrière / branche divergente » ;
- la commande exacte : `bin/kamal deploy -d production` ;
- la phrase finale « Déployer en production ? ».

Les choix sont *Oui, déployer* (reprends la question en `preview`) et *Non*. Si la version est déjà en production, nomme le premier choix *Oui, redéployer*.

Ne déploie qu'après un « oui » explicite. Une réponse vide, « sans préférence » ou ambiguë n'est pas un « oui » : explique-le et reposte la question. Sur « non », termine sans exécuter aucune commande Kamal, par le résumé de l'étape 8.

## 5. Déploiement

Lance exactement :

```bash
export PATH=/usr/local/rvm/rubies/ruby-3.4.6/bin:$PATH
bin/kamal deploy -d production
```

La commande construit l'image, la pousse, démarre le nouveau conteneur et attend que `GET /up` réponde 200 (30 secondes) : elle peut durer plusieurs minutes. Utilise le délai maximal de l'outil et ne l'interromps pas. Si l'outil signale un dépassement de délai, **ne relance pas** `deploy` : relève l'état avec `bin/kamal app version -d production` et `bin/kamal details -d production`, puis agis selon l'étape 7.

- Code de sortie 0 : passe à l'étape 6.
- Code de sortie non nul : passe à l'étape 7, cas « échec avant la bascule ».

## 6. Contrôle

Lis le domaine dans le fichier de configuration de production :

```bash
sed -nE 's/^[[:space:]]*APP_HOST:[[:space:]]*"?([^"#[:space:]]+)"?.*/\1/p' config/deploy.production.yml | head -1
```

Contrôle, dans cet ordre :

1. **Application joignable** : `curl -s -o /dev/null -w '%{http_code}' --max-time 15 https://<domaine>/up` doit renvoyer `200`. Un autre résultat : attends dix secondes et réessaie une fois.
2. **Version** : `bin/kamal app version -d production` (même filtre qu'à l'étape 3) doit renvoyer le hash complet de `HEAD` (`git rev-parse HEAD`).
3. **Conteneurs** : `bin/kamal details -d production`, dont tu résumes l'état (conteneur de l'application et `kamal-proxy` démarrés).

Si le domaine est introuvable (fichier ou clé `APP_HOST` absents), ne fais que les contrôles 2 et 3 et dis que le contrôle HTTP a été sauté.

Tout est conforme : passe au résumé (étape 8). Sinon, passe à l'étape 7, cas « échec après le déploiement ».

## 7. Échec

Lis d'abord les logs du dernier conteneur créé, y compris un conteneur arrêté. N'utilise pas `bin/kamal app logs` : il ne lit que les conteneurs en service et montrerait l'ancienne version, pas celle qui a échoué.

```bash
bin/kamal server exec -d production 'docker logs --tail 60 $(docker ps -a --latest --quiet --filter label=service=fideback --filter label=destination=production --filter label=role=web) 2>&1'
```

Garde les apostrophes : le `$(...)` doit être évalué sur le serveur. Montre les lignes utiles (erreurs, `InvalidMessage`, migration qui échoue) sans reproduire de valeur sensible.

**Échec avant la bascule** (`deploy` a renvoyé un code non nul : build, push ou healthcheck) : l'ancienne version reste en service tant que le nouveau conteneur n'a pas répondu. Confirme-le avec `bin/kamal app version -d production`, qui doit renvoyer `<prod>`. Dis-le explicitement. **Ne propose pas de retour arrière**, il n'y a rien à annuler. Explique la cause probable d'après les logs, ne relance pas `deploy` et termine par le résumé.

**Échec après le déploiement** (`deploy` a réussi, mais le contrôle de l'étape 6 est en échec) : montre le résultat du contrôle et les logs. Précise qu'un échec du contrôle HTTP peut venir du reverse proxy ou du DNS plutôt que de l'application, par exemple quand la version et les conteneurs sont corrects. Si une version précédente `<prod>` est connue (hash complet lu à l'étape 3), propose le retour arrière dans une question séparée, qui demande son propre « oui » : « Revenir à `<prod>` avec `bin/kamal rollback <prod> -d production` ? ». La commande exacte et la version figurent dans la question. Sans version précédente connue, ne propose rien.

- Sur « oui » : lance `bin/kamal rollback <prod> -d production`, puis refais le contrôle de l'étape 6. Si Kamal répond que la version n'est plus disponible sur le serveur (conteneur supprimé), affiche l'erreur, ne réessaie pas.
- Sur « non » : ne fais rien de plus.

## 8. Résumé

Termine par un résumé court :
- branche, hash court et titre du `HEAD`, état poussé ou non ;
- version précédente en production ;
- déploiement : refusé, réussi, ou échoué (avant la bascule ou après le déploiement) ;
- contrôle : code HTTP de `/up` (ou « sauté »), version en production, état des conteneurs ;
- retour arrière : proposé ou non, fait ou non.
