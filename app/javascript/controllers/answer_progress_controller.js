import { Controller } from "@hotwired/stimulus"

// Compteur des champs obligatoires qu'il reste à renseigner avant de pouvoir soumettre (notes et commentaires).
// Le serveur rend l'état de départ ; ce contrôleur le recalcule à chaque saisie. Un champ est renseigné si sa valeur n'est pas
// vide une fois les espaces retirés, comme côté serveur. Le bouton « Soumettre » n'est jamais désactivé : le serveur reste la règle.
// Les phrases sont celles de `remaining_fields_text` (RespondentFormsHelper).
export default class extends Controller {
  static targets = ["field", "status"]

  connect() {
    this.update()
    this.revealFirstMissing()
  }

  // Après un refus, le premier champ manquant porte `autofocus` : Turbo lui donne le focus mais remet la page en haut, donc il peut
  // rester hors écran. On le centre dans la fenêtre, une fois le rendu terminé ; `scroll-padding-bottom` (CSS) évite la barre d'actions.
  revealFirstMissing() {
    const field = this.element.querySelector("[autofocus]")
    if (!field) return

    requestAnimationFrame(() => requestAnimationFrame(() => field.scrollIntoView({ block: "center" })))
  }

  update() {
    const remaining = this.fieldTargets.filter((field) => field.value.trim() === "").length
    this.statusTarget.textContent = this.text(remaining)
    this.statusTarget.classList.toggle("is-done", remaining === 0)
  }

  text(remaining) {
    if (remaining === 0) return "Tout est renseigné : vous pouvez soumettre."
    if (remaining === 1) return "Il reste 1 champ à renseigner."
    return `Il reste ${remaining} champs à renseigner.`
  }
}
