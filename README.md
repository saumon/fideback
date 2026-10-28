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

## E-mails en développement

En développement aucun e-mail (invitations, réinitialisation de mot de passe) n'est envoyé : ils sont tous interceptés par [letter_opener_web](https://github.com/fgrehm/letter_opener_web) et consultables dans le navigateur sur `/letter_opener` (par exemple http://localhost:3000/letter_opener). La boîte est servie par l'application elle-même, ce qui fonctionne aussi quand le développement se fait sur une machine distante.

Un lien « Dev : boîte mail (letter_opener) » est affiché tout en bas de chaque page, côté manager comme côté sondé, **uniquement en développement**. La route et le lien n'existent ni en test ni en production.

Les liens contenus dans les e-mails utilisent l'hôte et le port définis par `APP_HOST` et `APP_PORT` (par défaut `localhost` et `3000`). Si vous accédez à l'application par une autre adresse, par exemple depuis le réseau local, créez un fichier `.env` à la racine (ignoré par git, chargé par `dotenv-rails`) :

```bash
APP_HOST=192.168.1.23
APP_PORT=3000
```

Redémarrez le serveur après toute modification. Les e-mails déjà interceptés conservent l'ancien lien : videz la boîte avec « Clear » ou renvoyez-les (bouton *Renvoyer* sur la page de la campagne).

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
- Tant que la campagne est en cours, le manager peut renvoyer l'invitation (même lien) à un sondé qui n'a pas encore soumis, via le bouton *Renvoyer* ; la date de dernière invitation s'affiche dans le tableau des sondés.
- Le manager suit l'avancement et lit, par managé, les moyennes et les commentaires attribués à leur auteur.
- Les réponses sont fermées à la clôture de la campagne ou à la date limite.

## Déploiement (Kamal)

Le déploiement est configuré dans `config/deploy.yml` (voir la [documentation Kamal](https://kamal-deploy.org)). À renseigner avant le premier déploiement : serveur, registre d'images, domaine, et la variable `APP_HOST` (hôte utilisé dans les liens des e-mails ; en développement, la même variable se règle dans `.env`, voir plus haut). Les paramètres SMTP se placent dans les credentials (`bin/rails credentials:edit`, clés `smtp`) puis se décommentent dans `config/environments/production.rb`.

```bash
bin/kamal setup           # premier déploiement
bin/kamal deploy          # déploiements suivants
```

La base SQLite et le stockage vivent dans le volume persistant `fideback_storage` : pensez à le sauvegarder.
