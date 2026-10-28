# Design

## Context

Voir proposal.md pour la motivation. État actuel : un seul mailer (`RespondentMailer#invitation`), deux layouts HTML sans footer (`application`, `respondent`), aucune configuration de livraison en développement. `test.rb` utilise `:test` et `production.rb` n'a pas de SMTP configuré : ces deux environnements ne bougent pas.

## Goals / Non-Goals

**Goals:**
- Tout email émis en développement est consultable dans le navigateur, via l'app elle-même.
- Un lien visible en bas de chaque page HTML, en développement uniquement.

**Non-Goals:**
- SMTP réel en développement et module `MailerSettings` (écarté, voir Décisions).
- Aucune exposition de la boîte hors développement.

## Decisions

**`letter_opener_web` plutôt que `letter_opener`.** La boîte est servie à une URL de l'app (`/letter_opener`). `letter_opener` seul ouvre un navigateur local ou écrit sur le disque du serveur, ce qui ne convient pas à un développement sur machine distante. C'est le choix de lockswap, pour la même raison.

**Montage de l'engine conditionné à `Rails.env.development?` dans `routes.rb`.** Le gem n'est chargé qu'en développement (groupe Bundler) : monter la route sans condition ferait échouer le boot en production et en test (constante inconnue). La condition évite aussi toute exposition accidentelle.

**Pas de module `MailerSettings` / bascule SMTP.** Fideback n'a aucun SMTP aujourd'hui ; le module de lockswap serait du code mort. Alternative : le reprendre tel quel pour pouvoir tester du vrai SMTP en dev. Écartée, à rouvrir le jour où la production en aura besoin.

**Un partial `layouts/_dev_footer.html.erb` rendu depuis les deux layouts.** Le mail part côté manager mais s'ouvre côté sondé (`respondent.html.erb`) : le lien doit exister dans les deux. Le partial porte lui-même la condition `Rails.env.development?` et rend un `<footer>` avec un lien `target="_blank"` vers `/letter_opener`. La condition dans le partial plutôt que dans chaque layout évite de la dupliquer. Le lien utilise `letter_opener_web.letters_path` (helper de l'engine, qui n'existe qu'en dev) plutôt qu'un chemin écrit en dur, afin de suivre le point de montage.

**Style minimal** : une classe `.dev-footer` (texte réduit, bordure haute, ton grisé) dans `application.css`, pour qu'on ne le prenne pas pour une fonctionnalité produit.

## Risks / Trade-offs

- [Le helper de l'engine n'existe qu'en dev] → il n'est appelé que dans le partial protégé par `Rails.env.development?`.
- [La condition `development?` n'est pas testable directement en environnement `test`] → on teste l'absence du lien en `test` (l'exigence qui compte) et on vérifie le cas dev manuellement.
- [Un `Gemfile.lock` modifié sans bundle en production] → le gem est dans `group :development` ; `bundle install --without development` (ou le `BUNDLE_WITHOUT` du Dockerfile) l'exclut.
