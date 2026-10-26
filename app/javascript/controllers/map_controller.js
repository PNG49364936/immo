import { Controller } from "@hotwired/stimulus"

const STYLE_URL = "https://basemaps.cartocdn.com/gl/positron-gl-style/style.json"
const PARIS_BOUNDS = [[2.224, 48.815], [2.47, 48.902]]

// Palette froid → chaud, alignée sur le thème (bleu Haussmann → rouge brique).
const PRICE_COLOR = [
  "interpolate", ["linear"], ["get", "m2"],
  7000, "#27507a",
  9000, "#6f9bb5",
  10500, "#d9b45f",
  12500, "#d0703b",
  16000, "#9c2a20"
]

const euros = new Intl.NumberFormat("fr-FR", { style: "currency", currency: "EUR", maximumFractionDigits: 0 })

export default class extends Controller {
  static values = { salesUrl: String, contoursUrl: String }

  connect() {
    this.selected = null
    this.map = new maplibregl.Map({
      container: this.element,
      style: STYLE_URL,
      bounds: PARIS_BOUNDS,
      fitBoundsOptions: { padding: 24 },
      attributionControl: { compact: true }
    })
    this.map.addControl(new maplibregl.NavigationControl({ showCompass: false }), "top-right")
    this.map.on("load", () => {
      this.map.resize()
      this.map.fitBounds(PARIS_BOUNDS, { padding: 24, duration: 0 })
      this.#setup()
    })
  }

  disconnect() {
    this.map?.remove()
  }

  focus({ detail: { number } }) {
    this.#highlight(number)
    const feature = this.contours?.features.find((f) => f.id === number)
    if (feature) this.map.fitBounds(this.#bbox(feature.geometry), { padding: 48, duration: 900 })
  }

  reset() {
    this.#highlight(null)
    this.map.fitBounds(PARIS_BOUNDS, { padding: 24, duration: 900 })
  }

  async #setup() {
    this.contours = await (await fetch(this.contoursUrlValue)).json()

    this.map.addSource("contours", { type: "geojson", data: this.contours })
    this.map.addSource("sales", { type: "geojson", data: this.salesUrlValue })

    this.map.addLayer({
      id: "contours-fill", type: "fill", source: "contours",
      paint: {
        "fill-color": "#1f3a5f",
        "fill-opacity": ["case", ["boolean", ["feature-state", "selected"], false], 0.06, 0]
      }
    })
    this.map.addLayer({
      id: "sales", type: "circle", source: "sales",
      paint: {
        "circle-color": PRICE_COLOR,
        "circle-radius": ["interpolate", ["linear"], ["zoom"], 11, 1.6, 14, 3.5, 17, 8],
        "circle-opacity": 0.82,
        "circle-stroke-color": "#f4efe6",
        "circle-stroke-width": ["interpolate", ["linear"], ["zoom"], 12, 0, 15, 0.8]
      }
    })
    this.map.addLayer({
      id: "contours-line", type: "line", source: "contours",
      paint: {
        "line-color": "#1f3a5f",
        "line-width": ["case", ["boolean", ["feature-state", "selected"], false], 2.6, 0.8],
        "line-opacity": ["case", ["boolean", ["feature-state", "selected"], false], 1, 0.45]
      }
    })

    this.#bindInteractions()
  }

  #bindInteractions() {
    const popup = new maplibregl.Popup({ closeButton: false, offset: 10, className: "sale-popup" })

    this.map.on("click", "sales", (e) => {
      const { p, m2 } = e.features[0].properties
      popup.setLngLat(e.features[0].geometry.coordinates)
        .setHTML(`<strong>${euros.format(p)}</strong><span>${euros.format(m2)} / m²</span>`)
        .addTo(this.map)
    })

    // Clic dans un arrondissement (hors point de vente) → le sélectionne dans la liste.
    this.map.on("click", (e) => {
      if (this.map.queryRenderedFeatures(e.point, { layers: ["sales"] }).length) return
      const [area] = this.map.queryRenderedFeatures(e.point, { layers: ["contours-fill"] })
      popup.remove()
      if (area && area.id !== this.selected) {
        window.dispatchEvent(new CustomEvent("map:pick", { detail: { number: area.id } }))
      }
    })

    this.map.on("mouseenter", "sales", () => (this.map.getCanvas().style.cursor = "pointer"))
    this.map.on("mouseleave", "sales", () => (this.map.getCanvas().style.cursor = ""))
  }

  #highlight(number) {
    if (!this.map.getSource("contours")) return
    if (this.selected) this.map.setFeatureState({ source: "contours", id: this.selected }, { selected: false })
    if (number) this.map.setFeatureState({ source: "contours", id: number }, { selected: true })
    this.selected = number

    // Les ventes hors de l'arrondissement choisi s'estompent.
    this.map.setPaintProperty("sales", "circle-opacity",
      number ? ["case", ["==", ["get", "a"], number], 0.9, 0.12] : 0.82)
  }

  #bbox(geometry) {
    const coords = geometry.coordinates.flat(geometry.type === "MultiPolygon" ? 2 : 1)
    const lngs = coords.map((c) => c[0])
    const lats = coords.map((c) => c[1])
    return [[Math.min(...lngs), Math.min(...lats)], [Math.max(...lngs), Math.max(...lats)]]
  }
}
