import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static get targets() {
    return ["url"];
  }

  get href() {
    return this.urlTarget.href;
  }

  click(e) {
    Turbo.visit(this.href);
  }
}
