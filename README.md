<div align="center">

<h1>
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/logo/fideback-logo-dark.png">
    <img src="docs/logo/fideback-logo.png" alt="Fideback" width="380">
  </picture>
</h1>

**Préparez vos entretiens individuels de fin d'année avec les retours de ceux qui travaillent avec vos équipes.**

[![Spec-Driven Development: OpenSpec](https://img.shields.io/badge/SDD-OpenSpec-6f42c1)](https://github.com/Fission-AI/OpenSpec)
[![Ruby 3.4](https://img.shields.io/badge/Ruby-3.4-CC342D?logo=ruby&logoColor=white)](.ruby-version)
[![Rails 8.1](https://img.shields.io/badge/Rails-8.1-D30001?logo=rubyonrails&logoColor=white)](https://rubyonrails.org)
[![Hotwire](https://img.shields.io/badge/Hotwire-Turbo%20%2B%20Stimulus-1d1d1f)](https://hotwired.dev)
[![SQLite](https://img.shields.io/badge/SQLite-3-003B57?logo=sqlite&logoColor=white)](https://www.sqlite.org)
[![Déployé avec Kamal](https://img.shields.io/badge/d%C3%A9ploy%C3%A9%20avec-Kamal-2f6fed)](https://kamal-deploy.org)
[![Style : RuboCop](https://img.shields.io/badge/style-rubocop--rails--omakase-red)](https://github.com/rails/rubocop-rails-omakase)
[![Licence : MIT](https://img.shields.io/badge/licence-MIT-green)](LICENSE)
[![Dependabot](https://img.shields.io/badge/Dependabot-activ%C3%A9-025e8c?logo=dependabot&logoColor=white)](.github/dependabot.yml)

</div>

---

## Sommaire

- [Présentation](#présentation)
- [Développé en SDD avec OpenSpec](#développé-en-sdd-avec-openspec)
- [Fonctionnalités](#fonctionnalités)
- [Pile technique](#pile-technique)
- [Démarrage rapide](#démarrage-rapide)
- [Configuration](#configuration)
- [Tests et qualité](#tests-et-qualité)
- [Déploiement](#déploiement)
- [Structure du dépôt](#structure-du-dépôt)
- [Contribuer](#contribuer)
- [Licence](#licence)

## Présentation

Fideback aide les managers à préparer leurs entretiens individuels de fin d'année. Un manager crée une **campagne de feedback** pour une liste finie de **managés**, interroge une liste finie de **sondés** (par un lien personnel, sans compte à créer), puis consulte une **synthèse nominative** par managé : moyennes, commentaires, auteurs.

```
Manager ──crée──▶ Campagne ──lance──▶ Sondés reçoivent un lien personnel par e-mail
                                           │
                       note (1 à 5) et commente chaque managé
                                           │
Manager ◀── synthèse nominative par managé ◀┘
```

Interface en **français uniquement**, polices auto-hébergées (aucun CDN externe), pensée pour le mobile comme pour le bureau.

## Développé en SDD avec OpenSpec

Fideback a été **piloté en Spec-Driven Development (SDD)** avec [OpenSpec](https://github.com/Fission-AI/OpenSpec) : aucune fonctionnalité n'a été écrite sans spécification préalable, et le code est produit avec un assistant IA (Claude Code) qui travaille à partir de ces spécifications.

Le principe : **la spécification précède le code et reste la source de vérité**. Chaque évolution suit le même cycle :

| Étape | Commande | Résultat |
|---|---|---|
| 1. Explorer | `/opsx:explore` | l'idée est discutée et le code existant est lu, sans rien écrire |
| 2. Proposer | `/opsx:propose` | un *change* contenant `proposal.md` (pourquoi), `specs/` (exigences et scénarios), `design.md` (comment) et `tasks.md` |
| 3. Appliquer | `/opsx:apply` | l'assistant implémente les tâches une à une, avec des tests |
| 4. Archiver | `/opsx:archive` | les exigences du change sont fusionnées dans les spécifications de référence |

Ce que cela donne dans le dépôt :

- [`openspec/specs/`](openspec/specs/) : les **spécifications de référence**, une par capacité (authentification, campagnes, synthèse, invitations, connexion par lien unique, navigation…). Chaque exigence est formulée en *doit* et accompagnée de scénarios *Étant donné / Quand / Alors* vérifiables.
- [`openspec/changes/archive/`](openspec/changes/archive/) : l'**historique de toutes les évolutions**, chacune avec sa proposition, ses décisions de conception et ses tâches. Le dépôt se lit comme un journal de décisions.
- [`.claude/`](.claude/) : les commandes et skills qui outillent le workflow, dont `saumon-finish`, qui clôt un travail (vérifications, commit, push), `saumon-dependabot`, qui intègre une branche Dependabot dans `dev`, et `saumon-deploy`, qui déploie en production après confirmation.

Les spécifications se valident avec `openspec validate --all --strict`. Le [fonctionnement détaillé](docs/fonctionnement.md) en est la lecture rapide.

## Fonctionnalités

**Pour les managers**
- Inscription avec activation du compte par e-mail, connexion, réinitialisation du mot de passe.
- Campagnes (brouillon → en cours → clôturée) avec questions par défaut modifiables, suppression d'une campagne brouillon ou clôturée.
- Annuaire d'équipe réutilisable d'une campagne à l'autre, rôles *managé* et/ou *sondable*.
- Suivi de l'avancement, relance des sondés, clôture automatique quand tous ont répondu (avec un e-mail au manager), synthèse nominative par managé.
- Notifications Telegram en plus des e-mails, par un bot créé par le manager et réglé dans « Mon compte » (envoi seul, sans webhook).

**Pour les sondés**
- Lien personnel par e-mail, **sans compte**.
- Note de 1 à 5 et commentaire par managé, tous obligatoires pour soumettre, avec un compteur de champs restants ; enregistrement de la progression, soumission définitive.
- Information claire : les réponses sont nominatives.

**Pour l'administrateur** (premier compte créé)
- Liste des utilisateurs, invitation d'un manager par e-mail et suppression d'un manager.
- *Danger zone* : fermer les inscriptions, exiger une **connexion par lien unique** envoyé par e-mail (second facteur).

**Expérience**
- Menu surligné selon l'écran, tiroir de navigation accessible sur mobile, toasts, boîtes de confirmation au style du site, page 404 sur mesure, e-mails au style du site.
- Respect de `prefers-reduced-motion` et de l'accessibilité clavier.

## Pile technique

| Domaine | Choix |
|---|---|
| Langage et framework | Ruby 3.4.6, Ruby on Rails 8.1.4 (monolithe) |
| Front | Hotwire (Turbo, Stimulus), importmap, Propshaft, CSS sans framework |
| Données | SQLite, avec Solid Queue, Solid Cache et Solid Cable (aucun Redis) |
| Authentification | [Devise](https://github.com/heartcombo/devise) (confirmable, recoverable, rememberable) |
| Tests | Minitest, Capybara et Selenium (Chrome headless) |
| Qualité | RuboCop (rails-omakase), Brakeman, bundler-audit, importmap audit |
| Déploiement | Docker et [Kamal](https://kamal-deploy.org) |
| Spécification | [OpenSpec](https://github.com/Fission-AI/OpenSpec) |

## Démarrage rapide

**Prérequis** : Ruby 3.4.6 (voir [`.ruby-version`](.ruby-version)) et Bundler. Chrome n'est nécessaire que pour les tests système et la régénération des icônes (Selenium Manager le télécharge).

```bash
git clone git@github.com:saumon/fideback.git
cd fideback
bin/setup --skip-server   # installe les gems et prépare la base
bin/dev                   # http://localhost:3000
```

`bin/dev` écoute sur le réseau local ; `BINDING=127.0.0.1 bin/dev` restreint à la machine. **Le premier compte créé devient administrateur.**

### E-mails en développement

Sans configuration SMTP, aucun e-mail ne part : ils sont interceptés par [letter_opener_web](https://github.com/fgrehm/letter_opener_web) et consultables sur [`/letter_opener`](http://localhost:3000/letter_opener) (lien « Dev : boîte mail » en bas de chaque page, **en développement uniquement**). C'est là que se trouvent le lien d'activation et les liens de connexion.

## Configuration

Les variables se placent dans un fichier `.env` à la racine (ignoré par git, chargé par `dotenv-rails`) en développement, et dans `config/deploy.yml` et `.kamal/secrets-common` en production.

| Variable | Rôle |
|---|---|
| `APP_HOST`, `APP_PORT`, `APP_PROTOCOL` | adresse publique utilisée dans les liens des e-mails (défaut : `localhost`, `3000`). Dès qu'`APP_HOST` est défini, seul `APP_PORT` fixe le port |
| `SMTP_ADDRESS`, `SMTP_PORT`, `SMTP_USERNAME`, `SMTP_PASSWORD` | **obligatoires** pour envoyer des e-mails : s'il en manque une, SMTP est considéré comme non configuré |
| `SMTP_DOMAIN`, `SMTP_AUTHENTICATION` (`plain`), `SMTP_ENABLE_STARTTLS_AUTO` (`true`), `SMTP_OPENSSL_VERIFY_MODE` | facultatives |
| `SMTP_SENDER` (ou `MAILER_SENDER`) | adresse d'expéditeur de tous les e-mails |
| `SMTP_ENABLED=false` | n'envoie rien même si la configuration est complète |
| `ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY`, `ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY`, `ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT` | facultatives : clés de chiffrement des tokens Telegram, qui remplacent les clés `active_record_encryption` des credentials |

À défaut de variables, les clés `smtp` des credentials sont utilisées (`bin/rails credentials:edit`). En développement, une configuration SMTP complète dans `.env` fait envoyer les e-mails pour de vrai au lieu de les intercepter. Redémarrez le serveur après toute modification ; les e-mails déjà interceptés gardent l'ancien lien.

Sans configuration SMTP exploitable, l'application démarre mais écrit un avertissement `[mail]` dans le journal : les managers ne pourraient plus activer leur compte.

Les tokens des bots Telegram sont chiffrés en base par Active Record. Les clés `active_record_encryption` sont déjà dans les credentials de développement et de production ; pour un nouvel environnement, générez-les avec `bin/rails db:encryption:init` et copiez le bloc affiché dans `bin/rails credentials:edit` (ajoutez `-e production` pour la production). **Ne changez pas ces clés** : les tokens déjà enregistrés deviendraient illisibles, et chaque manager concerné devrait ressaisir le sien.

## Tests et qualité

```bash
bin/rails test            # modèles, services, vues, intégration, mailers
bin/rails test:system     # parcours complets dans Chrome headless
bin/rubocop               # style
bin/brakeman              # analyse de sécurité
bin/ci                    # enchaîne l'ensemble (hors tests système)
```

Le projet n'a pas d'intégration continue sur GitHub : les vérifications se lancent en local, et `/saumon-finish` les enchaîne (tests, RuboCop, tests système, `bin/ci`) avant chaque commit. `bin/ci` couvre aussi les audits de sécurité (Brakeman, gems, importmap). [Dependabot](.github/dependabot.yml) propose chaque semaine la mise à jour des dépendances ; `/saumon-dependabot` intègre ces branches dans `dev` après vérification.

## Déploiement

Le déploiement utilise [Kamal](https://kamal-deploy.org). `config/deploy.yml` est un modèle avec des valeurs d'exemple ; les valeurs réelles (serveur, `APP_HOST`, variables `SMTP_*`) se placent dans `config/deploy.production.yml`, **ignoré par git**, que Kamal fusionne par-dessus avec `-d production`. `SMTP_PASSWORD` et `RAILS_MASTER_KEY` sont des secrets : `.kamal/secrets-common` donne les valeurs par défaut (lues dans l'environnement du poste de déploiement et dans `config/master.key`), et `.kamal/secrets.production`, **ignoré par git**, les surcharge avec les valeurs réelles de la production.

L'application est prévue derrière un reverse proxy qui termine le HTTPS (Nginx Proxy Manager, par exemple) et transmet en HTTP au port 80 du serveur : `assume_ssl` et `force_ssl` sont activés en production, sans `proxy.ssl` dans Kamal. Le reverse proxy doit activer les websockets (Turbo, Action Cable). Pour terminer le HTTPS avec Kamal à la place, renseignez le bloc `proxy` de `deploy.yml`.

```bash
bin/kamal setup -d production     # premier déploiement
bin/kamal deploy -d production    # déploiements suivants
bin/kamal console -d production   # console Rails en production
```

`/saumon-deploy` enchaîne les contrôles locaux, affiche les commits qui s'ajoutent à la version en production et, après confirmation, exécute `bin/kamal deploy -d production` puis vérifie que l'application répond. Les vérifications de code relèvent de `/saumon-finish`, à lancer avant.

Pour les notifications Telegram, le serveur doit pouvoir joindre `api.telegram.org` en HTTPS sortant, et les clés `active_record_encryption` des credentials de production ne doivent pas changer d'un déploiement à l'autre (voir [Configuration](#configuration)).

Les migrations s'exécutent au démarrage du conteneur. Les bases SQLite et le stockage vivent dans le volume persistant `fideback_storage` : **pensez à le sauvegarder**.

**Reprise en cas de problème d'e-mails** : si la connexion par lien unique est activée et que l'envoi des e-mails tombe en panne, plus personne ne peut se connecter. Le retour arrière se fait dans la console : `bin/rails runner 'Setting.login_link_required = false'`.

### Landing page (GitHub Pages)

`docs/index.html` est une page de présentation statique, sans JavaScript ni ressource externe, publiée à <https://saumon.github.io/fideback/> par GitHub Pages. Dans les paramètres du dépôt, **Pages** doit être réglé sur *Deploy from a branch*, branche `master`, dossier `/docs` : la page n'est en ligne qu'après la fusion de `dev` dans `master`. Elle reprend le style de l'accueil de l'application, mais `docs/landing.css` en est une **copie réduite, non synchronisée** : quand le style de l'accueil change (couleurs, boutons, logo, scène, animations), reportez le changement dans `docs/landing.css`. `docs/og.png` est l'image de prévisualisation des liens partagés (1200x630). `docs/fonctionnement.md` est aussi servi par Pages, en texte brut.

## Structure du dépôt

```
app/                  modèles, contrôleurs, vues, contrôleurs Stimulus, CSS
config/               configuration Rails, routes, déploiement Kamal
db/                   migrations et schémas (principal, cache, queue, cable)
docs/                 landing page statique (GitHub Pages) et fonctionnement détaillé écran par écran
openspec/specs/       spécifications de référence (source de vérité)
openspec/changes/     évolutions en cours, et archive/ pour l'historique
script/icons          génération des icônes binaires à partir de public/icon.svg
test/                 tests unitaires, d'intégration et système
.claude/              commandes et skills du workflow SDD
```

### Icône

Le dessin de l'icône (un F encre et son ombre rose) a une seule source : `public/icon.svg`, qui passe le F en clair en thème sombre. Après toute modification, régénérez `public/icon.png`, `public/apple-touch-icon.png` et `public/favicon.ico` avec `ruby script/icons` (Chrome headless). Le « F » du logotype (`.brand-name::first-letter` dans `app/assets/stylesheets/application.css`) reprend ce style : ajustez-le aussi si les couleurs changent. La barre du haut porte en plus une marque à deux bulles de dialogue, dessinée en SVG dans `app/views/layouts/_brand_mark.html.erb` et colorée par les variables CSS du site : elle suit donc un changement de palette sans autre retouche. Ses animations sont en CSS et coupées quand le système demande un mouvement réduit.

## Contribuer

Le projet suit le Spec-Driven Development, donc **on ne code pas avant d'avoir spécifié**.

1. Installez [OpenSpec](https://github.com/Fission-AI/OpenSpec) puis décrivez l'évolution avec `/opsx:explore`, puis `/opsx:propose`.
2. Relisez la proposition, les exigences (*Étant donné / Quand / Alors*) et les tâches.
3. Implémentez avec `/opsx:apply`, puis archivez avec `/opsx:archive`.
4. Vérifiez que tout passe : `bin/rails test`, `bin/rubocop`, `bin/rails test:system` et `bin/ci`.
5. Les commits suivent la convention [Conventional Commits](https://www.conventionalcommits.org) (`feat:`, `fix:`, `docs:`, `chore:`…), en anglais.

L'interface est exclusivement en français.

## Licence

Fideback est distribué sous [licence MIT](LICENSE).
