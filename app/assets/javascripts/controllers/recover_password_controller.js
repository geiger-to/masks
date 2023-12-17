import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static get targets() {
    return ["password", "submit"];
  }

  connect() {
    this.password = this.passwordTarget.value;
    this.syncState();
  }

  updatePassword(e) {
    this.password = e.target.value;
    this.syncState();
  }

  syncState() {
    this.submitTarget.disabled = !this.password?.length;
  }
}
