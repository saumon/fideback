import { Controller } from "@hotwired/stimulus"

// Choix du modèle de questions d'une nouvelle campagne : charge les questions du modèle dans le cadre « questions »,
// sans recharger la page, pour ne pas perdre le nom, la date limite ni les contacts déjà saisis.
export default class extends Controller {
  static targets = ["frame"]
  static values = { url: String }

  choose(event) {
    const url = new URL(this.urlValue, window.location.origin)
    url.searchParams.set("template_id", event.target.value)
    this.frameTarget.src = url.toString()
  }
}
