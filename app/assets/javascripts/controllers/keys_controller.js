import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static get targets() {
    return ["settings"];
  }

  connect() {
    // this.email = this.;emailTarget.value;
    // this.pass = this.passwordTarget.value;
    // this.syncState();
  }

  toggleSettings(e) {
    this.settingsTarget.classList.toggle("hidden");

    e.preventDefault();
    e.stopPropagation();
  }
}
