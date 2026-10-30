# Design

## Context

Voir proposal.md pour la motivation. Aujourd'hui `public/404.html` est servie pour toute erreur 404 en production : une page autonome, sans la police ni la feuille de style (le CSS d'application est empreinté par Propshaft, une page statique ne peut pas le référencer). Observé dans le code :

- `config.exceptions_app` n'est pas défini : Rails sert les fichiers de `public/`.
- En développement, `consider_all_requests_local = true` : une adresse inconnue affiche la page de débogage de Rails, pas la page 404. En test, `show_exceptions = :rescuable` : les 404 passent par la page publique.
- Les 404 de l'application viennent de `find_by!`/`find` (enregistrements) et de `Admin::BaseController`, qui lève `ActionController::RoutingError`.
- Le layout `application` affiche une navigation qui dépend de la session ; le layout `respondent` n'a que la marque, sans lien de compte.
- Le style existant : six « voix » colorées, ombres décalées, rebonds (`--bounce`), animations coupées par `prefers-reduced-motion`, scène de synthèse sur l'accueil.

## Goals / Non-Goals

**Goals:**
- Une page 404 qui est une vraie page de l'application (layout, police, couleurs, animations), drôle, avec un retour clair.
- Un chemin unique pour toutes les causes de 404 : adresse inconnue, enregistrement absent, accès refusé à l'espace d'administration.

**Non-Goals:**
- Les pages 400, 422, 500 et 406 ne changent pas.
- Pas de texte tiré au hasard : un seul texte, testable.
- Pas de page de débogage différente en développement : les erreurs 500 y gardent la page de Rails.

## Decisions

**`config.exceptions_app` pointe sur les routes, avec un `ErrorsController#not_found`.** C'est le mécanisme standard de Rails pour rendre une erreur avec une vraie vue. La route `match "/404", to: "errors#not_found", via: :all` sert à Rails pour toute 404 interceptée ; elle n'est pas joignable directement, `public/404.html` masquant un GET sur `/404`. La prévisualisation passe par une route de développement `/dev/404`, comme la boîte `letter_opener`. Alternative écartée : réécrire `public/404.html` avec le style en ligne ; elle ne peut ni utiliser la police ni la feuille de style empreintées, ni la barre du haut, et donc pas « le style du site ».

**Seule la 404 passe par l'application.** Les autres codes continuent d'utiliser `public/`, ce qui garde un chemin simple pour les erreurs graves.

**Secours : `exceptions_app` est enveloppée.** Un `lambda` appelle les routes et, si le rendu lève une exception, répond avec `ActionDispatch::PublicExceptions` (qui sert `public/404.html`). Sinon Rails ne renverrait qu'un « 500 Internal Server Error » en texte brut. `public/404.html` n'est donc pas supprimée, et le test des icônes continue de la couvrir.

**`ErrorsController`.** Il hérite d'`ApplicationController`, saute `authenticate_manager!`, force le format HTML (une adresse en `.json` reçoit la même page, avec le statut 404) et répond `status: :not_found`. Le layout est `respondent` quand l'adresse d'origine (`request.env["action_dispatch.original_path"]`) commence par `/repondre`, `application` sinon : un sondé sans compte ne voit pas « Créer un compte ». La session et la navigation d'un manager connecté doivent être disponibles dans cette requête relancée par `ShowExceptions` ; à vérifier par un test (le menu « Mes campagnes » est présent sur une 404 d'un manager connecté) et, si ce n'est pas le cas, la navigation retombe sur l'état visiteur plutôt que de planter.

**Garde de l'administration : rendre la page au lieu de lever.** `Admin::BaseController#require_admin!` fait `render "errors/not_found", status: :not_found` plutôt que lever `RoutingError`. La réponse est la même qu'en production, et en développement le refus affiche la page drôle et non la page de débogage « Routing Error ». Une adresse réellement inconnue reste, elle, une page de débogage en développement : on la prévisualise sur `/dev/404`.

**Contenu : l'univers de la synthèse.** La page détourne l'écran phare du site : un « 404 » dont les chiffres rebondissent chacun avec une voix, et une carte inclinée « Synthèse : cette page » (même cadre que `.home-scene`) où trois voix donnent leur avis sur la page disparue, avec une moyenne introuvable. Proposition de texte, à ajuster à l'implémentation sans changer les exigences :
- Étiquette : « Erreur 404 » ; titre : « Cette page est introuvable. » ; chapeau : « Nous avons interrogé tout le monde : personne ne l'a vue. »
- Carte, trois voix (RM, TB, LN, déjà connues de l'accueil) : « Toujours disponible, sauf à cette adresse. » / « Pourrait mieux communiquer son emplacement. » / « Le meilleur binôme pour une mise en production un vendredi… quand elle existe. »
- Moyenne : « — » avec la mention « introuvable » ; boutons : « Retour à l'accueil » ou « Mes campagnes ».
Le texte met en scène une page, jamais une personne réelle.

**Styles dans `application.css`**, sous un préfixe `.page-errors` (le `body` reçoit déjà `page-<controller_name>`), en réutilisant les variables, `--bounce` et `@keyframes` existants. Le bloc `prefers-reduced-motion` global coupe déjà les animations ; la page est lisible sans elles. Les éléments purement décoratifs (chiffres animés, avatars) sont `aria-hidden`, et le titre est lu une seule fois comme sur l'accueil.

## Risks / Trade-offs

- [Une erreur dans la page dynamique cacherait la 404] → Le secours vers `public/404.html` et un test qui simule l'échec du rendu.
- [`ShowExceptions` relance la requête sans toute la pile de middlewares : session et flash peuvent manquer] → Test sur la navigation d'un manager connecté ; repli sur la navigation de visiteur.
- [Humour qui vieillit ou ne plaît pas] → Le texte est isolé dans une seule vue, facile à changer sans toucher aux specs.

## Migration Plan

Aucune donnée. Déploiement normal ; retour arrière : retirer `exceptions_app` et la route, ce qui rend la main à `public/404.html`.
