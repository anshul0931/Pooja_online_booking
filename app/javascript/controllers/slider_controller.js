import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["slide", "dot"]
  static values = { index: { type: Number, default: 0 }, interval: { type: Number, default: 5000 } }

  connect() {
    this.startAutoSlide()
  }

  disconnect() {
    this.stopAutoSlide()
  }

  indexValueChanged() {
    this.showCurrentSlide()
  }

  showCurrentSlide() {
    if (this.slideTargets.length === 0) return

    this.slideTargets.forEach((element, i) => {
      element.classList.toggle("active", i === this.indexValue)
    })
    
    this.dotTargets.forEach((element, i) => {
      element.classList.toggle("active", i === this.indexValue)
    })
  }

  next() {
    this.indexValue = (this.indexValue + 1) % this.slideTargets.length
  }

  prev() {
    this.indexValue = (this.indexValue - 1 + this.slideTargets.length) % this.slideTargets.length
  }

  goTo(event) {
    const index = parseInt(event.currentTarget.dataset.index)
    if (!isNaN(index)) {
      this.indexValue = index
      this.startAutoSlide() // reset interval on manual click
    }
  }

  startAutoSlide() {
    this.stopAutoSlide()
    this.timer = setInterval(() => this.next(), this.intervalValue)
  }

  stopAutoSlide() {
    if (this.timer) {
      clearInterval(this.timer)
    }
  }
}
