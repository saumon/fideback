import { Controller } from "@hotwired/stimulus"

// Compte à rebours d'un bouton désactivé : « Renvoyer le lien dans 42 s », puis le bouton se réactive.
// Le serveur rend déjà le bouton désactivé avec les secondes restantes et refuse de toute façon une demande
// trop tôt : sans JavaScript, la page reste correcte, mais le texte ne bouge pas.
// L'échéance est calculée une fois pour toutes : un onglet en arrière-plan, dont les minuteries sont ralenties,
// affiche quand même le bon temps à son retour.
export default class extends Controller {
  static targets = ["button"]
  static values = { seconds: Number, label: String }

  connect() {
    this.deadline = Date.now() + this.secondsValue * 1000
    this.tick()
    this.timer = setInterval(() => this.tick(), 250)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  tick() {
    const remaining = Math.ceil((this.deadline - Date.now()) / 1000)

    if (remaining <= 0) {
      clearInterval(this.timer)
      this.buttonTarget.textContent = this.labelValue
      this.buttonTarget.disabled = false
    } else {
      this.buttonTarget.textContent = `${this.labelValue} dans ${remaining} s`
    }
  }
}
