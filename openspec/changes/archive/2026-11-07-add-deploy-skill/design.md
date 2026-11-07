# Design

## Context

Voir `proposal.md` pour la motivation. Les contraintes qui façonnent l'approche :

- Les skills `saumon-*` fixent la forme : frontmatter avec `disable-model-invocation: true`, étapes numérotées, `AskUserQuestion` pour chaque question (le texte écrit avant l'appel pouvant ne pas s'afficher, l'information décisive figure dans la question), une confirmation par écriture, bloc « Refus de continuer », réponses en français.
- Kamal 2.12 déploie le **commit** (image tagguée par le hash git, construite depuis un clone local). Un arbre sale ne l'arrête pas : il affiche seulement un avertissement jaune « ignoring these uncommitted changes ». Rien d'autre ne protège donc d'un déploiement différent de ce que l'on croit.
- La configuration réelle de production est hors dépôt (dépôt public) : `config/deploy.production.yml`, `.kamal/secrets.production`, `config/credentials/production.key`, plus un fichier de mot de passe SMTP référencé par `.kamal/secrets.production`. Une commande Kamal sans `-d production` viserait l'IP d'exemple du modèle.
- Ruby n'est pas dans le `PATH` (`/usr/local/rvm/rubies/ruby-3.4.6/bin`). Docker doit être utilisable sans `sudo` par la session qui lance Kamal.
- Un déploiement dure de quelques dizaines de secondes à plusieurs minutes (build, push, healthcheck de 30 s). En cas d'échec du healthcheck, Kamal laisse l'ancien conteneur en service.

## Goals / Non-Goals

**Goals:**
- Un parcours unique qui montre ce qui va partir, demande un « oui » explicite, déploie, puis vérifie le résultat.
- Détecter avant Kamal les manques locaux qui provoquent des échecs tardifs ou ambigus.
- Ne contenir aucune valeur propre à la production (IP, domaine, chemin de secret, mot de passe) : le skill est versionné dans un dépôt public.

**Non-Goals:**
- Aucune vérification de code (tests, RuboCop, `bin/ci`) : `/saumon-finish` les a déjà exécutées.
- Aucun `kamal setup`, `remove`, `app exec` ni modification de la configuration : le skill ne lance que `deploy` et, sur confirmation, `rollback`.
- Pas de sauvegarde de la base avant déploiement, pas de notification.

## Decisions

1. **Skill en Markdown pur, `disable-model-invocation: true`.** Un déploiement en production ne doit jamais se déclencher implicitement. Alternative : script shell dans `script/` ; écartée, la lecture des échecs et les confirmations interactives sont le rôle de l'agent, comme pour les autres skills.

2. **Arrêt si l'arbre n'est pas propre.** Parce que Kamal ne s'arrête pas lui-même (voir Context), le skill liste les fichiers modifiés ou non suivis et s'arrête, sans stasher ni committer à la place de l'utilisateur. Alternative : laisser Kamal avertir ; écartée, l'avertissement se perd dans la sortie d'un build.

3. **N'importe quelle branche, affichée dans la confirmation ; `HEAD` non poussé signalé sans bloquer.** Décision de l'utilisateur. Après un `git fetch`, le skill indique la branche, le hash court et le titre du `HEAD`, et précise si `origin/<branche>` le contient (ou si la branche n'a pas d'amont). Une branche de fonctionnalité ou `dependabot/*` n'est pas refusée ; la mention reste visible dans la question.

4. **Contrôle des prérequis avant tout appel à Kamal.** Présence de `config/deploy.production.yml`, `.kamal/secrets.production` et `config/credentials/production.key` ; Docker utilisable (`docker info`) ; secrets résolus par `bin/kamal secrets print -d production`, dont le skill ne contrôle que la **présence et la longueur non nulle** de `RAILS_MASTER_KEY` et `SMTP_PASSWORD`, sans jamais afficher une valeur (la sortie est filtrée avant d'être lue). Chaque manque est nommé avec son effet. Cela couvre les échecs réellement rencontrés : secrets introuvables avec `-d production`, clé qui ne déchiffre pas les credentials, `permission denied` sur le socket Docker.

5. **Montrer ce qui va partir.** `bin/kamal app version -d production` donne la version en cours (hash). Le skill compare avec `HEAD` :
   - version déjà en production : le dire, et demander si l'on redéploie quand même ;
   - version ancêtre de `HEAD` : lister `git log --oneline <version>..HEAD` ;
   - version absente de l'historique local, ou non ancêtre : le signaler (retour en arrière, branche divergente, version inconnue) et ne pas inventer de liste ;
   - version illisible (serveur injoignable, premier déploiement) : le dire et continuer à la confirmation, Kamal échouera de lui-même si le serveur est réellement inaccessible.

6. **Une seule confirmation avant le déploiement**, avec la commande exacte (`bin/kamal deploy -d production`), la branche, le `HEAD`, l'état poussé ou non et la liste des commits dans la question elle-même. Le « non » termine sans rien exécuter. Aucune option ajoutée à la commande (`--skip-push`, `--version`…).

7. **Exécution avec `PATH` Ruby et un délai large.** La commande peut dépasser le délai d'une commande ordinaire : le skill laisse le temps au build et ne l'interrompt pas. La sortie contenant le nom de variables d'environnement mais pas leurs valeurs, elle peut être affichée ; le skill n'affiche jamais le contenu des fichiers de secrets.

8. **Vérification après déploiement.** Le domaine est lu à l'exécution dans `config/deploy.production.yml` (clé `APP_HOST`), jamais écrit dans le skill. Contrôles : `curl` sur `https://<APP_HOST>/up` attend `200`, `bin/kamal app version -d production` doit renvoyer le hash du `HEAD`, `bin/kamal details -d production` donne l'état des conteneurs. Si `APP_HOST` est introuvable, seul le contrôle de version est fait, ce que le skill dit.

9. **Échec et retour arrière.** Deux cas distincts :
   - `kamal deploy` échoue avant la bascule (build, push, healthcheck) : l'ancienne version est toujours en service, ce que le skill confirme par `bin/kamal app version -d production`. Il affiche les dernières lignes de logs du dernier conteneur créé, et ne propose **pas** de rollback, inutile ici.
   - `kamal deploy` réussit mais le contrôle de l'étape 8 échoue : le skill affiche les mêmes logs et propose `bin/kamal rollback <version précédente> -d production` (version relevée à l'étape 5), dans une question séparée avec son propre « oui ». Sans version précédente connue, il n'en propose pas. Il précise que l'échec peut venir du reverse proxy ou du DNS plutôt que de l'application, et laisse l'utilisateur décider.

   Les logs se lisent avec `bin/kamal server exec -d production 'docker logs --tail 60 $(docker ps -a --latest --quiet --filter label=service=fideback --filter label=destination=production --filter label=role=web) 2>&1'` et non avec `bin/kamal app logs` : ce dernier ne lit que les conteneurs en service (statuts `running` et `restarting`) et montrerait donc l'ancienne version après un échec de healthcheck, pas le conteneur qui a échoué. La commande est vérifiée en lecture seule sur le dépôt réel, le `$(...)` étant entre apostrophes pour être évalué sur le serveur.

10. **Périmètre des commandes Kamal.** Le skill n'exécute que `secrets print` (filtré), `app version`, `deploy`, `details`, `server exec` limité à la lecture de logs (`docker logs`) et, sur confirmation, `rollback`. Aucune autre commande qui écrit sur le serveur.

## Risks / Trade-offs

- [Déployer un état différent de ce que l'on croit] → arrêt sur arbre sale, branche et `HEAD` dans la confirmation, liste des commits qui s'ajoutent à la production.
- [Fuite d'un secret dans la conversation] → `secrets print` n'est lu qu'à travers un filtre qui ne garde que nom et longueur ; aucune lecture directe des fichiers de secrets.
- [Valeurs de production dans un dépôt public] → aucune valeur dans le skill ; `APP_HOST` lu à l'exécution dans un fichier ignoré par git.
- [Déploiement long, session qui coupe] → le skill n'interrompt pas la commande ; en cas de doute sur l'état, `bin/kamal details -d production` et `app version` le disent.
- [Base SQLite : migration qui échoue au démarrage du conteneur] → le healthcheck échoue, l'ancienne version reste en service ; les logs affichés montrent la cause. Aucune sauvegarde préalable n'est faite par le skill (hors périmètre) : la sauvegarde du CT sous Proxmox reste la protection des données.
- [Un `HEAD` non poussé est déployé] → accepté (décision de cadrage), mais signalé dans la confirmation, car la production ne serait pas retrouvable sur GitHub.
- [Redéploiement de la version déjà en production sans intérêt] → le skill le signale et demande confirmation plutôt que de refuser, un redéploiement pouvant être voulu (changement de variable d'environnement ou de secret).
