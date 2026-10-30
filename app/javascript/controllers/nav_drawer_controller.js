import { Controller } from "@hotwired/stimulus"

// Tiroir de navigation des petits écrans (sous 40rem, voir le CSS). Sans ce contrôleur, le bouton reste masqué et la
// navigation reste un simple bloc de liens : `data-nav-ready` active les règles du tiroir.
// Ouvert, le tiroir est modal : le focus y reste, le reste de la page est inerte et ne défile plus.
// Turbo remplace le <body> à chaque navigation, ce qui referme le tiroir ; le cache de Turbo est vidé de son état ouvert.
const MOBILE = "(max-width: 40rem)"
const BEHIND = "main, .dev-footer, .site-header .brand, .site-header .header-end > .btn"
const FOCUSABLE = "a[href], button:not([disabled])"

export default class extends Controller {
  static targets = ["toggle", "panel"]

  connect() {
    this.mobile = window.matchMedia(MOBILE)
    this.onBreakpoint = () => { if (!this.mobile.matches) this.close({ restoreFocus: false }) }
    this.onBeforeCache = () => this.close({ restoreFocus: false })
    this.onKeydown = (event) => this.keydown(event)
    this.mobile.addEventListener("change", this.onBreakpoint)
    document.addEventListener("turbo:before-cache", this.onBeforeCache)

    // Rang de chaque entrée, pour la cascade d'apparition.
    const entries = this.panelTarget.querySelectorAll(":scope > a, :scope > .nav-account > *")
    entries.forEach((entry, index) => entry.style.setProperty("--i", index))

    this.toggleTarget.hidden = false
    this.element.dataset.navReady = ""
    // Les transitions du tiroir ne s'arment qu'après le premier rendu, pour qu'il ne glisse pas vers sa place fermée.
    requestAnimationFrame(() => requestAnimationFrame(() => { this.element.dataset.navArmed = "" }))
  }

  disconnect() {
    this.mobile.removeEventListener("change", this.onBreakpoint)
    document.removeEventListener("turbo:before-cache", this.onBeforeCache)
    this.close({ restoreFocus: false })
    delete this.element.dataset.navReady
    delete this.element.dataset.navArmed
  }

  toggle() {
    this.isOpen ? this.close() : this.open()
  }

  open() {
    if (this.isOpen) return
    this.element.classList.add("is-open")
    this.toggleTarget.setAttribute("aria-expanded", "true")
    this.toggleTarget.setAttribute("aria-label", "Fermer le menu")
    document.documentElement.classList.add("nav-open")
    this.behind.forEach((element) => { element.inert = true })
    document.addEventListener("keydown", this.onKeydown)
    this.panelTarget.querySelector(FOCUSABLE)?.focus()
  }

  close({ restoreFocus = true } = {}) {
    if (!this.isOpen) return
    this.element.classList.remove("is-open")
    this.toggleTarget.setAttribute("aria-expanded", "false")
    this.toggleTarget.setAttribute("aria-label", "Ouvrir le menu")
    document.documentElement.classList.remove("nav-open")
    this.behind.forEach((element) => { element.inert = false })
    document.removeEventListener("keydown", this.onKeydown)
    if (restoreFocus) this.toggleTarget.focus()
  }

  get isOpen() {
    return this.element.classList.contains("is-open")
  }

  get behind() {
    return document.querySelectorAll(BEHIND)
  }

  keydown(event) {
    if (event.key === "Escape") {
      this.close()
    } else if (event.key === "Tab") {
      this.keepFocusInside(event)
    }
  }

  // Tab et Maj+Tab bouclent entre les éléments du tiroir et le bouton, dans l'ordre du document.
  keepFocusInside(event) {
    const stops = [...this.panelTarget.querySelectorAll(FOCUSABLE), this.toggleTarget]
    const last = stops.length - 1
    const index = stops.indexOf(document.activeElement)
    if (event.shiftKey && index <= 0) {
      event.preventDefault()
      stops[last].focus()
    } else if (!event.shiftKey && index === last) {
      event.preventDefault()
      stops[0].focus()
    }
  }
}
