import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (/Android|iPhone/i.test(navigator.userAgent)) {
      this.element.classList.add("mobile");
    }
  }
}
