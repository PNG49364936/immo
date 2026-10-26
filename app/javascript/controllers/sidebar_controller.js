import { Controller } from "@hotwired/stimulus"

// Liste des arrondissements : surligne la ligne active et prévient la carte.
export default class extends Controller {
  static targets = ["row"]

  select(event) {
    const number = Number(event.currentTarget.dataset.number)
    this.#activate(number)
    window.dispatchEvent(new CustomEvent("arrondissement:select", { detail: { number } }))
  }

  reset() {
    this.#activate(null)
    window.dispatchEvent(new CustomEvent("arrondissement:reset"))
  }

  // Clic sur un arrondissement directement dans la carte.
  pick({ detail: { number } }) {
    this.rowTargets.find((row) => Number(row.dataset.number) === number)?.click()
  }

  #activate(number) {
    this.rowTargets.forEach((row) => {
      const active = Number(row.dataset.number) === number
      row.classList.toggle("is-active", active)
      if (active) row.scrollIntoView({ block: "nearest", behavior: "smooth" })
    })
  }
}
