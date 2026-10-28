import { Controller } from "@hotwired/stimulus"

// Boutons 1 à 5 posés à côté du champ numérique de note : ils le remplissent,
// et le champ, toujours saisissable, garde la valeur envoyée au serveur.
export default class extends Controller {
  static targets = ["input", "pick"]

  connect() {
    this.sync()
  }

  pick({ params: { value } }) {
    this.inputTarget.value = value
    this.sync()
  }

  sync() {
    const value = Number(this.inputTarget.value)
    this.pickTargets.forEach((button) => {
      button.setAttribute("aria-pressed", Number(button.dataset.ratingValueParam) === value)
    })
  }
}
