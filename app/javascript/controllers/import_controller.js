import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

// Bouton « Rafraîchir les données » : désactivé pendant l'import,
// puis recharge la page quand le statut (diffusé en direct) passe à « done ».
export default class extends Controller {
  static targets = ["button", "status"]

  start() {
    this.wasRunning = true
    this.#toggle(true)
  }

  statusTargetConnected(element) {
    const state = element.dataset.state
    const running = state === "pending" || state === "running"
    this.#toggle(running)
    if (running) this.wasRunning = true
    if (state === "done" && this.wasRunning) Turbo.visit(window.location.pathname, { action: "replace" })
  }

  #toggle(running) {
    if (!this.hasButtonTarget) return
    this.buttonTarget.disabled = running
    this.buttonTarget.textContent = running ? "Import en cours…" : "Rafraîchir les données"
  }
}
