import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["field"]

  connect() {
    // Disable native browser tooltips
    this.element.setAttribute("novalidate", "true")
  }

  validate(event) {
    const field = event.target
    this.validateField(field)
  }

  validateField(field) {
    if (!field || !field.willValidate) return

    const feedbackElement = field.parentElement.querySelector(".invalid-feedback")

    // Custom check for phone formatting
    if (field.type === "tel" && field.value !== "") {
      const isPhoneValid = /^[0-9]{10,15}$/.test(field.value)
      if (!isPhoneValid) {
        field.setCustomValidity("Phone number must be between 10 and 15 digits")
      } else {
        field.setCustomValidity("")
      }
    }

    if (field.checkValidity()) {
      field.classList.remove("is-invalid")
      field.classList.add("is-valid")
      if (feedbackElement) {
        feedbackElement.textContent = ""
      }
    } else {
      field.classList.remove("is-valid")
      field.classList.add("is-invalid")
      if (feedbackElement) {
        feedbackElement.textContent = field.validationMessage || "This field is mandatory"
      }
    }
  }

  submit(event) {
    let isValid = true

    this.fieldTargets.forEach((field) => {
      this.validateField(field)
      if (!field.checkValidity()) {
        isValid = false
      }
    })

    if (!isValid) {
      event.preventDefault()
      event.stopPropagation()
      
      // Smooth scroll to the first invalid input
      const firstInvalid = this.element.querySelector(".is-invalid")
      if (firstInvalid) {
        firstInvalid.scrollIntoView({ behavior: "smooth", block: "center" })
        firstInvalid.focus()
      }
    }
  }
}
