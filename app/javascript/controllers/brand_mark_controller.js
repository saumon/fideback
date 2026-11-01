import { Controller } from "@hotwired/stimulus"

// Marque du logo : l'arrivée des bulles n'a lieu qu'une fois par chargement complet de la page.
// Turbo remplace le <body> à chaque visite : le logo y est recréé et ses animations CSS repartent. Une fois l'arrivée
// terminée, on le note sur <html>, que Turbo conserve, et le CSS ne la rejoue plus (`:root[data-brand-arrived]`).
export default class extends Controller {
  connect() {
    if (document.documentElement.hasAttribute("data-brand-arrived")) return

    this.onEnd = (event) => {
      if (event.animationName !== "bubble-in" || !event.target.classList.contains("arrive-front")) return
      document.documentElement.setAttribute("data-brand-arrived", "")
    }
    this.element.addEventListener("animationend", this.onEnd)
  }

  disconnect() {
    this.element.removeEventListener("animationend", this.onEnd)
  }
}
