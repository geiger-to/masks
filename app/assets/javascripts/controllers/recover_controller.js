import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static get targets() {
    return ['input', 'submit'];
  }

  connect() {
    this.input = this.inputTarget.value;
    this.syncState();
  }

  updateInput(e) {
    this.input = e.target.value;
    this.syncState();
  }

  goBack(e) {
    e?.preventDefault();
    e?.stopPropagation();

    window.history.back();
  }

  syncState() {
    this.submitTarget.disabled = !this.input?.length;
  }
}
