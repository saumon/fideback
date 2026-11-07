# Proposal

## Why

Fideback se déploie en production avec Kamal (`bin/kamal deploy -d production`). La commande est courte, mais elle suppose plusieurs choses que l'on oublie facilement : un arbre propre (Kamal déploie le commit, pas le répertoire de travail), quatre fichiers locaux ignorés par git, Ruby dans le `PATH`, Docker utilisable sans `sudo`. Un échec arrive tard (le build puis le healthcheck prennent plusieurs dizaines de secondes) et ne dit pas toujours d'où il vient. Un déploiement est aussi une écriture sur un serveur réel : il doit toujours passer par une confirmation qui montre ce qui va partir. Un skill dédié, sur le modèle de `/saumon-finish` et `/saumon-dependabot`, rend ce circuit systématique.

## What Changes

- Ajout du skill projet `/saumon-deploy` (`.claude/skills/saumon-deploy/SKILL.md`), invoqué explicitement, jamais automatiquement.
- Le skill contrôle l'état local : arbre propre, branche et commit courants, fichiers de configuration de production présents, secrets résolus, Docker utilisable. Tout manque est signalé avant de lancer Kamal.
- Il montre ce qui va partir : le commit courant (branche, hash, titre), s'il est poussé sur `origin`, et les commits qui s'ajoutent à la version actuellement en production.
- Il demande une confirmation explicite, avec la commande exacte dans la question, puis exécute `bin/kamal deploy -d production`.
- Après le déploiement, il vérifie que l'application répond et que la version en production est celle qui vient d'être déployée.
- En cas d'échec, il affiche les derniers logs du conteneur et indique si l'ancienne version est restée en service. Un retour arrière (`bin/kamal rollback`) n'est proposé que si le déploiement s'est terminé et que l'application ne répond pas, avec sa propre confirmation.

Décisions de cadrage : n'importe quelle branche peut être déployée (la branche est affichée dans la confirmation) ; un `HEAD` non poussé est signalé sans bloquer ; le skill ne relance aucune vérification (tests, RuboCop, `bin/ci`), car `/saumon-finish` les a déjà exécutées.

Hors périmètre : le premier déploiement (`kamal setup`), les vérifications de code, la sauvegarde de la base avant déploiement, la modification de `config/deploy.yml` ou des fichiers de production, et toute modification de l'application Rails.

## Capabilities

### New Capabilities

Aucune : l'outillage de développement ne change aucun comportement de l'application. Le changement déclare `skip_specs: true`.

### Modified Capabilities

Aucune.

## Impact

- Nouveau fichier : `.claude/skills/saumon-deploy/SKILL.md`. Le dépôt étant public, il ne contient ni IP, ni domaine, ni chemin de secret : le domaine est lu à l'exécution dans `config/deploy.production.yml`, ignoré par git.
- Mention du skill dans `.claude/skills/project-conventions/SKILL.md` et dans le README (liste de `.claude/` et section *Déploiement*).
- Effets à l'usage : un déploiement sur le serveur de production, et éventuellement un retour arrière, chacun soumis à confirmation.
