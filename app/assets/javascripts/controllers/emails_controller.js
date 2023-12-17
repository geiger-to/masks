import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static get targets() {
    return ["email", "password", "submit"];
  }

  connect() {
    this.email = this.emailTarget.value;
    this.pass = this.passwordTarget.value;

    this.syncState();
  }

  updateEmail(e) {
    this.email = e.target.value;
    this.syncState();
  }

  updatePassword(e) {
    this.pass = e.target.value;
    this.syncState();
  }

  syncState() {
    this.submitTarget.disabled = !this.email?.includes("@") || !this.pass;
  }
}
