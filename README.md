# Fideback

Aide les managers à préparer leurs entretiens individuels de fin d'année : un manager crée une **campagne de feedback** pour une liste finie de **managés**, interroge une liste finie de **sondés** (par lien personnel, sans compte), puis consulte une **synthèse nominative** par managé.

Monolithe Ruby on Rails 8.1.4 (Hotwire, Propshaft, Solid Queue/Cache/Cable, SQLite), authentification des managers avec [devise](https://github.com/heartcombo/devise). Interface en français uniquement.

## Prérequis

- Ruby 3.4.6 (voir `.ruby-version`)
- Bundler
- Pour les tests système : Chrome (téléchargé automatiquement par Selenium Manager)

## Installation

```bash
bin/setup --skip-server   # installe les gems et prépare la base
```

## Lancer l'application

```bash
bin/dev                   # http://localhost:3000, joignable sur le réseau local (BINDING=127.0.0.1 pour restreindre)
```

En développement les e-mails (invitations, réinitialisation de mot de passe) ne sont pas envoyés ; consultez le journal `log/development.log`.

## Tests et qualité

```bash
bin/rails test            # modèles, services, contrôleurs, mailers
bin/rails test:system     # parcours complet (Chrome headless)
bin/rubocop               # style
bin/brakeman              # analyse de sécurité
bin/ci                    # enchaîne l'ensemble (hors tests système)
```

## Fonctionnement

- Les **managers** s'inscrivent librement et gèrent leurs campagnes (brouillon → en cours → clôturée).
- Au lancement, chaque **sondé** reçoit un e-mail avec un lien personnel (`/repondre/<jeton>`). Il note (1 à 5) et/ou commente chaque managé, enregistre sa progression, puis soumet définitivement. Il est informé que ses réponses sont **nominatives**.
- Le manager suit l'avancement et lit, par managé, les moyennes et les commentaires attribués à leur auteur.
- Les réponses sont fermées à la clôture de la campagne ou à la date limite.

## Déploiement (Kamal)

Le déploiement est configuré dans `config/deploy.yml` (voir la [documentation Kamal](https://kamal-deploy.org)). À renseigner avant le premier déploiement : serveur, registre d'images, domaine, et la variable `APP_HOST` (hôte utilisé dans les liens des e-mails). Les paramètres SMTP se placent dans les credentials (`bin/rails credentials:edit`, clés `smtp`) puis se décommentent dans `config/environments/production.rb`.

```bash
bin/kamal setup           # premier déploiement
bin/kamal deploy          # déploiements suivants
```

La base SQLite et le stockage vivent dans le volume persistant `fideback_storage` : pensez à le sauvegarder.
