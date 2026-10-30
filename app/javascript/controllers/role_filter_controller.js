import { Controller } from "@hotwired/stimulus"

// Filtre d'affichage des contacts par rôle. Les lignes écartées sont seulement
// masquées : elles restent dans le formulaire et sont enregistrées telles quelles.
// Le filtre s'applique au clic, pas quand on coche un rôle, pour qu'une ligne
// ne disparaisse pas sous le curseur.
export default class extends Controller {
  static targets = ["choice", "row"]

  choose(event) {
    this.role = event.currentTarget.dataset.role
    this.choiceTargets.forEach((choice) => {
      const active = choice === event.currentTarget
      choice.classList.toggle("is-active", active)
      choice.setAttribute("aria-pressed", active)
    })
    this.rowTargets.forEach((row) => this.filter(row))
  }

  // Une ligne pas encore enregistrée reste visible, pour qu'on voie ce qu'on vient d'ajouter.
  filter(row) {
    const box = this.role && row.querySelector(`[data-role='${this.role}']`)
    row.classList.toggle("is-filtered-out", Boolean(box) && !box.checked && row.dataset.newRecord !== "true")
  }
}
