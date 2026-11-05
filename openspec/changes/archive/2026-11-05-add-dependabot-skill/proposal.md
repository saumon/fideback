# Proposal

## Why

Dependabot ouvre régulièrement des branches de mise à jour (`dependabot/bundler/...`, `dependabot/github_actions/...`). Les intégrer à la main est répétitif et risqué : il faut les rebaser sur `dev`, rejouer toutes les vérifications, forcer le push, puis merger. Un skill dédié, sur le modèle de `/saumon-finish`, rend ce circuit systématique et impose les garde-fous (tests verts avant toute écriture distante, confirmations explicites).

## What Changes

- Ajout du skill projet `/saumon-dependabot` (`.claude/skills/saumon-dependabot/SKILL.md`), invoqué explicitement, jamais automatiquement.
- Le skill liste les branches `origin/dependabot/*` par date de commit croissante (la plus ancienne d'abord) et demande laquelle intégrer.
- La branche choisie est rebasée localement sur `origin/dev`, sans rien pousser.
- Une fois rebasée, il lance `bin/rails test`, `bin/rubocop`, `bin/rails test:system` puis `bin/ci`, comme `/saumon-finish`. Au moindre échec, il s'arrête sans écrire à distance.
- Si tout est au vert, deux confirmations séparées :
  1. pousser la branche rebasée avec `--force-with-lease` (jamais `--force`) ;
  2. merger la branche dans `dev` avec `--no-ff`, puis pousser `dev`.
- Après le merge, il propose de supprimer la branche distante (confirmation séparée).

Hors périmètre : toute modification de l'application Rails, la configuration de Dependabot (`.github/dependabot.yml`), la fusion de plusieurs branches en une seule passe, la gestion des PR via l'API GitHub, la modification de `/saumon-finish`.

## Capabilities

### New Capabilities

Aucune : l'outillage de développement ne change aucun comportement de l'application. Le changement déclare `skip_specs: true`.

### Modified Capabilities

Aucune.

## Impact

- Nouveau fichier : `.claude/skills/saumon-dependabot/SKILL.md`.
- Ligne à ajouter dans `.claude/skills/project-conventions/SKILL.md` (mention du skill) et, si le README décrit les skills, dans la section *Contribuer*.
- Effets distants du skill à l'usage : push forcé d'une branche Dependabot, push de `dev`, suppression de branche distante, tous soumis à confirmation.
