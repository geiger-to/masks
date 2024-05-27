import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static get targets() {
    return ["table"];
  }

  connect() {
    // this.email = this.;emailTarget.value;
    // this.pass = this.passwordTarget.value;
    // this.syncState();
  }
}
