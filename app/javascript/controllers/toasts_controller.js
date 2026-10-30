import { Controller } from "@hotwired/stimulus"

// Toasts des messages consécutifs à une action. La colonne passe dans la couche supérieure du navigateur
// (popover) pour rester au-dessus de tout. Les toasts rendus par le serveur sont réinsérés un instant plus tard :
// un lecteur d'écran n'annonce de façon fiable que ce qui arrive dans une zone aria-live déjà présente.
// Le minuteur d'une notice est l'animation de sa barre (voir le CSS) : sa fin ferme le toast ; une alerte n'en a pas.
const ANNOUNCE_DELAY = 100
const MAX_TOASTS = 3
const SWIPE_RATIO = 0.35
const SWIPE_SPEED = 0.5 // px/ms

export default class extends Controller {
  static targets = ["toast"]

  connect() {
    if (this.element.showPopover) {
      this.element.popover = "manual"
      this.element.showPopover()
    }

    this.syncVisibility = () => this.element.classList.toggle("is-paused", document.hidden)
    document.addEventListener("visibilitychange", this.syncVisibility)
    this.syncVisibility()
    this.liftAboveStickyBar()

    const toasts = this.toastTargets
    toasts.forEach((toast) => toast.remove())
    this.announcing = setTimeout(() => {
      toasts.forEach((toast) => this.show(toast))
      this.element.dataset.ready = ""
    }, ANNOUNCE_DELAY)
  }

  disconnect() {
    clearTimeout(this.announcing)
    document.removeEventListener("visibilitychange", this.syncVisibility)
    this.barObserver?.disconnect()
    if (this.element.popover && this.element.matches(":popover-open")) this.element.hidePopover()
  }

  show(toast) {
    if (!toast.classList.contains("flash-alert")) {
      const length = toast.querySelector("p").textContent.trim().length
      const duration = Math.min(Math.max(3000 + 60 * length, 4000), 10000)
      toast.style.setProperty("--toast-duration", `${duration}ms`)
      toast.classList.add("is-timed")
    }
    this.element.append(toast)
    this.trim()
  }

  close({ currentTarget }) {
    this.dismiss(currentTarget.closest(".toast"))
  }

  expire(event) {
    if (event.animationName === "toast-timer") this.dismiss(event.currentTarget)
  }

  dismiss(toast) {
    if (toast.classList.contains("is-leaving")) return
    toast.classList.add("is-leaving")
    Promise.allSettled(toast.getAnimations().map((animation) => animation.finished)).then(() => toast.remove())
  }

  // Au-delà de la limite, la notice la plus ancienne part ; une alerte reste jusqu'à ce qu'on la ferme.
  trim() {
    const staying = this.toastTargets.filter((toast) => !toast.classList.contains("is-leaving"))
    const excess = staying.length - MAX_TOASTS
    if (excess <= 0) return
    staying.filter((toast) => !toast.classList.contains("flash-alert")).slice(0, excess).forEach((toast) => this.dismiss(toast))
  }

  // Balayage horizontal au doigt ou au stylet ; à la souris, glisser sert à sélectionner le texte.
  grab(event) {
    if (event.pointerType === "mouse" || event.target.closest("button")) return
    const toast = event.currentTarget
    const start = { x: event.clientX, time: event.timeStamp }
    let shift = 0

    const move = (moveEvent) => {
      shift = moveEvent.clientX - start.x
      toast.style.translate = `${shift}px 0`
      toast.style.opacity = 1 - Math.min(Math.abs(shift) / toast.offsetWidth, 1) * 0.6
    }
    const release = (releaseEvent) => {
      toast.removeEventListener("pointermove", move)
      toast.removeEventListener("pointerup", release)
      toast.removeEventListener("pointercancel", release)
      toast.classList.remove("is-dragging")

      const far = Math.abs(shift) > toast.offsetWidth * SWIPE_RATIO
      const fast = Math.abs(shift) > 24 && Math.abs(shift) / (releaseEvent.timeStamp - start.time) > SWIPE_SPEED
      if (releaseEvent.type === "pointerup" && (far || fast)) {
        toast.style.setProperty("--toast-exit", shift > 0 ? "100%" : "-100%")
        this.dismiss(toast)
      } else {
        toast.style.translate = ""
        toast.style.opacity = ""
      }
    }

    toast.setPointerCapture(event.pointerId)
    toast.classList.add("is-dragging")
    toast.addEventListener("pointermove", move)
    toast.addEventListener("pointerup", release)
    toast.addEventListener("pointercancel", release)
  }

  // Une barre d'actions collée en bas de l'écran (formulaire du sondé) resterait cachée sous les toasts.
  liftAboveStickyBar() {
    const bar = document.querySelector("[data-toasts-avoid]")
    if (!bar) return
    this.barObserver = new ResizeObserver(() => this.element.style.setProperty("--toasts-lift", `${bar.offsetHeight}px`))
    this.barObserver.observe(bar)
  }
}
