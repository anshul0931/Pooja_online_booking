import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "formCard", "successCard", "nameInput"]

  connect() {
    if (this.hasSuccessCardTarget) {
      this.successCardTarget.classList.add("d-none")
    }
  }

  submit(event) {
    event.preventDefault()
    
    // Check form validity
    if (!this.formTarget.checkValidity()) {
      this.formTarget.classList.add("was-validated")
      return
    }

    // Capture devotee name
    const devoteeName = this.nameInputTarget.value || "Devotee"

    // Perform smooth visual transition
    this.formCardTarget.style.transition = "opacity 0.4s ease, transform 0.4s ease"
    this.formCardTarget.style.opacity = "0"
    this.formCardTarget.style.transform = "scale(0.95)"

    setTimeout(() => {
      this.formCardTarget.classList.add("d-none")
      
      this.successCardTarget.classList.remove("d-none")
      this.successCardTarget.style.opacity = "0"
      this.successCardTarget.style.transform = "scale(0.95)"
      this.successCardTarget.style.transition = "opacity 0.4s ease, transform 0.4s ease"
      
      // Force repaint
      this.successCardTarget.offsetHeight 
      
      this.successCardTarget.style.opacity = "1"
      this.successCardTarget.style.transform = "scale(1)"
      
      // Update success card text dynamically
      const textContainer = this.successCardTarget.querySelector(".success-name-placeholder")
      if (textContainer) {
        textContainer.textContent = devoteeName
      }
    }, 400)
  }
}
