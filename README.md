# Fideback

Aide les managers à préparer leurs entretiens individuels de fin d'année : un manager crée une **campagne de feedback** pour une liste finie de **managés**, interroge une liste finie de **sondés** (par lien personnel, sans compte), puis consulte une **synthèse nominative** par managé.

Monolithe Ruby on Rails 8.1.4 (Hotwire, Propshaft, Solid Queue/Cache/Cable, SQLite), authentification des managers avec [devise](https://github.com/heartcombo/devise). Interface en français uniquement. Police Bricolage Grotesque auto-hébergée dans `app/assets/fonts/` (licence SIL OFL), sans CDN externe.

## Prérequis

- Ruby 3.4.6 (voir `.ruby-version`)
- Bundler
- Pour les tests système et la régénération des icônes (`script/icons`) : Chrome (téléchargé automatiquement par Selenium Manager)

## Installation

```bash
bin/setup --skip-server   # installe les gems et prépare la base
```

## Lancer l'application

```bash
bin/dev                   # http://localhost:3000, joignable sur le réseau local (BINDING=127.0.0.1 pour restreindre)
```

## E-mails en développement

En développement, sauf configuration SMTP complète dans `.env` (voir *Déploiement*), aucun e-mail (activation de compte, invitations, réinitialisation de mot de passe) n'est envoyé : ils sont tous interceptés par [letter_opener_web](https://github.com/fgrehm/letter_opener_web) et consultables dans le navigateur sur `/letter_opener` (par exemple http://localhost:3000/letter_opener). La boîte est servie par l'application elle-même, ce qui fonctionne aussi quand le développement se fait sur une machine distante.

Un lien « Dev : boîte mail (letter_opener) » est affiché tout en bas de chaque page, côté manager comme côté sondé, **uniquement en développement**. La route et le lien n'existent ni en test ni en production.

Les liens contenus dans les e-mails utilisent l'hôte et le port définis par `APP_HOST` et `APP_PORT` (par défaut `localhost` et `3000` ; dès qu'`APP_HOST` est défini, seul `APP_PORT` fixe le port). Si vous accédez à l'application par une autre adresse, par exemple depuis le réseau local, créez un fichier `.env` à la racine (ignoré par git, chargé par `dotenv-rails`) :

```bash
APP_HOST=192.168.1.23
APP_PORT=3000
```

Redémarrez le serveur après toute modification. Les e-mails déjà interceptés conservent l'ancien lien : videz la boîte avec « Clear » ou renvoyez-les (bouton *Renvoyer* sur la page de la campagne).

## Tests et qualité

```bash
bin/rails test            # modèles, services, vues, intégration, mailers
bin/rails test:system     # parcours complet, équipe et toasts (Chrome headless)
bin/rubocop               # style
bin/brakeman              # analyse de sécurité
bin/ci                    # enchaîne l'ensemble (hors tests système)
```

## Icône

Le dessin de l'icône (un F encre et son ombre rose) a une seule source : `public/icon.svg`, qui passe le F en clair quand le système est en thème sombre. Après toute modification de ce fichier, régénérez les versions binaires commitées, `public/icon.png`, `public/apple-touch-icon.png` (fond clair pour iOS) et `public/favicon.ico` :

```bash
ruby script/icons         # utilise Chrome headless, comme les tests système
```

Le « F » du logotype de la barre du haut reprend ce style en CSS (`.brand-name::first-letter` dans `app/assets/stylesheets/application.css`) : si les couleurs ou l'ombre de l'icône changent, ajustez-le aussi.

## Fonctionnement

- Les **managers** s'inscrivent librement, puis activent leur compte avec le lien reçu par e-mail (valable 24 heures, renvoi possible depuis la page « Vous n'avez pas reçu l'email de confirmation ? », un e-mail par adresse toutes les 5 minutes) : tant que le compte n'est pas activé, la connexion est refusée. Ils gèrent ensuite leurs campagnes (brouillon → en cours → clôturée). Les comptes créés avant l'introduction de l'activation sont considérés comme activés.
- Chaque manager tient son **équipe** dans l'écran *Mon équipe* (lien dans le menu) : nom, e-mail unique et rôle(s) *managé* et/ou *sondable*, avec un filtre par rôle. Une modification s'applique aussi aux campagnes en brouillon ; les campagnes lancées gardent leur copie. Au premier déploiement de cette fonctionnalité, une migration remplit l'équipe à partir des campagnes existantes.
- Le formulaire de campagne (création et modification, tant qu'elle est en brouillon) est pré-rempli avec des **questions par défaut**, qui s'ajoutent et se suppriment avec les boutons *Ajouter* et *Supprimer*. Les managés et les sondés se cochent parmi les contacts de l'équipe (bouton *Tout cocher*), ou s'ajoutent avec *Nouveau contact*, qui les enregistre aussi dans l'équipe. Une fois la campagne lancée, ces listes ne sont plus modifiables.
- Au lancement, chaque **sondé** reçoit un e-mail avec un lien personnel (`/repondre/<jeton>`). Il note (1 à 5) et/ou commente chaque managé, enregistre sa progression, puis soumet définitivement. Il est informé que ses réponses sont **nominatives**.
- Tant que la campagne est en cours, le manager peut renvoyer l'invitation (même lien) à un sondé qui n'a pas encore soumis, via le bouton *Renvoyer* ; la date de dernière invitation s'affiche dans le tableau des sondés.
- Le manager suit l'avancement et lit, par managé, les moyennes et les commentaires attribués à leur auteur.
- Les réponses sont fermées à la clôture de la campagne ou à la date limite.
- Les messages qui suivent une action (connexion, clôture, renvoi…) s'affichent en toasts par-dessus la page, en bas à droite (en bas sur toute la largeur sur mobile), sans décaler l'interface : les notices disparaissent seules après quelques secondes, les alertes restent jusqu'à ce qu'on les ferme. Les messages d'état (campagne terminée, réponses déjà soumises, erreurs d'un formulaire) restent dans la page.

## Déploiement (Kamal)

Le déploiement est configuré dans `config/deploy.yml` (voir la [documentation Kamal](https://kamal-deploy.org)). À renseigner avant le premier déploiement : serveur, registre d'images, domaine, et la variable `APP_HOST` (hôte utilisé dans les liens des e-mails ; en développement, la même variable se règle dans `.env`, voir plus haut). Les e-mails de production partent par un serveur SMTP configuré par variables d'environnement (ou, à défaut, par les clés `smtp` des credentials, `bin/rails credentials:edit`) :

| Variable | Rôle |
|---|---|
| `SMTP_ADDRESS`, `SMTP_PORT`, `SMTP_USERNAME`, `SMTP_PASSWORD` | obligatoires : s'il en manque une, SMTP est considéré comme non configuré |
| `SMTP_DOMAIN`, `SMTP_AUTHENTICATION` (`plain`), `SMTP_ENABLE_STARTTLS_AUTO` (`true`), `SMTP_OPENSSL_VERIFY_MODE` | facultatives |
| `SMTP_SENDER` (ou `MAILER_SENDER`) | adresse d'expéditeur de tous les e-mails |
| `SMTP_ENABLED=false` | n'envoie rien même si la configuration est complète |
| `APP_HOST`, `APP_PORT`, `APP_PROTOCOL` | adresse publique utilisée dans les liens des e-mails |

Sans configuration SMTP exploitable, l'application démarre mais écrit un avertissement `[mail]` dans le journal : les managers ne pourraient plus activer leur compte. `SMTP_PASSWORD` est un secret Kamal, lu dans l'environnement du poste de déploiement (`.kamal/secrets`). En développement, ces mêmes variables, placées dans `.env`, font envoyer les e-mails pour de vrai au lieu de les intercepter.

```bash
bin/kamal setup           # premier déploiement
bin/kamal deploy          # déploiements suivants
```

La base SQLite et le stockage vivent dans le volume persistant `fideback_storage` : pensez à le sauvegarder.
