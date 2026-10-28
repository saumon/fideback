import { Controller } from "@hotwired/stimulus"

// Ajout et suppression de lignes d'un formulaire à attributs imbriqués.
// Le <template> contient une ligne vide dont l'index vaut NEW_RECORD.
export default class extends Controller {
  static targets = ["container", "template", "row"]

  add(event) {
    event.preventDefault()
    const html = this.templateTarget.innerHTML.replaceAll("NEW_RECORD", Date.now().toString())
    this.containerTarget.insertAdjacentHTML("beforeend", html)
  }

  remove(event) {
    event.preventDefault()
    const row = event.target.closest("[data-nested-form-target='row']")

    if (row.dataset.newRecord === "true") {
      row.remove()
    } else {
      row.querySelector("input[name$='[_destroy]']").value = "1"
      row.hidden = true
    }
  }
}
