import { Controller } from "@hotwired/stimulus"

// Coche d'un coup toutes les cases d'une liste.
export default class extends Controller {
  static targets = ["box"]

  check() {
    this.boxTargets.forEach((box) => { box.checked = true })
  }
}
