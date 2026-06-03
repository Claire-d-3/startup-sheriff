import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["signupTab", "signinTab", "signupPanel", "signinPanel"]

  showSignup() {
    this.setActiveTab("signup")
  }

  showSignin() {
    this.setActiveTab("signin")
  }

  setActiveTab(mode) {
    const isSignup = mode === "signup"

    this.signupTabTarget.classList.toggle("is-active", isSignup)
    this.signinTabTarget.classList.toggle("is-active", !isSignup)
    this.signupTabTarget.setAttribute("aria-selected", isSignup)
    this.signinTabTarget.setAttribute("aria-selected", !isSignup)

    this.signupPanelTarget.classList.toggle("d-none", !isSignup)
    this.signinPanelTarget.classList.toggle("d-none", isSignup)
  }
}
