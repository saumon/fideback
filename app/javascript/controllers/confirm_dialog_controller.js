import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

// Boîte de confirmation des actions (lancer, clôturer, supprimer…), à la place de l'alerte du navigateur.
// Turbo appelle `Turbo.config.forms.confirm(message, formulaire, bouton)` quand un déclencheur porte
// `data-turbo-confirm` : la promesse rendue vaut true si l'utilisateur confirme, false sinon.
// Le message devient le titre. Trois attributs facultatifs, lus sur le bouton puis sur le formulaire :
// `data-turbo-confirm-detail` (phrase sous le titre), `-tone` (`danger` ou neutre) et `-icon` (send, lock, check, trash, warning).
// Le libellé de confirmation est celui du bouton cliqué. <dialog> fournit le fond inerte, le piège à focus et Échap.
const CANCEL = "cancel"
const OK = "ok"

export default class extends Controller {
  static targets = ["badge", "title", "detail", "cancel", "confirm", "icon"]

  connect() {
    this.previous = Turbo.config.forms.confirm
    this.handler = (message, form, submitter) => this.ask(message, form, submitter)
    Turbo.config.forms.confirm = this.handler

    this.onBeforeCache = () => { if (this.element.open) this.element.close(CANCEL) }
    this.onPointerDown = (event) => { this.pressedBackdrop = event.target === this.element }
    this.onClick = (event) => { if (this.pressedBackdrop && event.target === this.element) this.element.close(CANCEL) }
    document.addEventListener("turbo:before-cache", this.onBeforeCache)
    this.element.addEventListener("pointerdown", this.onPointerDown)
    this.element.addEventListener("click", this.onClick)
  }

  disconnect() {
    if (Turbo.config.forms.confirm === this.handler) Turbo.config.forms.confirm = this.previous
    document.removeEventListener("turbo:before-cache", this.onBeforeCache)
    this.element.removeEventListener("pointerdown", this.onPointerDown)
    this.element.removeEventListener("click", this.onClick)
  }

  ask(message, form, submitter) {
    // Navigateur sans <dialog> modal : l'alerte native garde la confirmation.
    if (typeof this.element.showModal !== "function") return Promise.resolve(window.confirm(message))
    if (this.element.open) return Promise.resolve(false)

    const read = (name) => submitter?.getAttribute(name) ?? form?.getAttribute(name)
    const danger = read("data-turbo-confirm-tone") === "danger"
    const iconName = read("data-turbo-confirm-icon") || (danger ? "warning" : "check")
    const detail = read("data-turbo-confirm-detail")

    this.element.dataset.tone = danger ? "danger" : "neutral"
    this.titleTarget.textContent = message
    this.detailTarget.textContent = detail || ""
    this.detailTarget.hidden = !detail
    this.badgeTarget.replaceChildren(this.icon(iconName))
    this.confirmTarget.textContent = this.labelOf(submitter)
    this.confirmTarget.classList.toggle("btn-solid-danger", danger)
    this.confirmTarget.classList.toggle("btn-primary", !danger)

    // Une action destructive démarre sur le retrait, pour qu'un Entrée distrait ne la confirme pas.
    const first = danger ? this.cancelTarget : this.confirmTarget
    const other = danger ? this.confirmTarget : this.cancelTarget
    first.setAttribute("autofocus", "")
    other.removeAttribute("autofocus")

    this.element.returnValue = CANCEL
    this.element.showModal()

    return new Promise((resolve) => {
      this.element.addEventListener("close", () => {
        const confirmed = this.element.returnValue === OK
        if (!confirmed && submitter?.isConnected) submitter.focus()
        resolve(confirmed)
      }, { once: true })
    })
  }

  labelOf(submitter) {
    if (submitter instanceof HTMLInputElement) return submitter.value
    return submitter?.textContent.trim() || "Confirmer"
  }

  icon(name) {
    const template = this.iconTargets.find((candidate) => candidate.dataset.name === name)
      || this.iconTargets.find((candidate) => candidate.dataset.name === "check")
    return template.content.cloneNode(true)
  }
}
