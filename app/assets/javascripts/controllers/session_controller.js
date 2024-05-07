import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { signup: Boolean }

  static get targets() {
    return [
      "nickname",
      "oneTimeCode",
      "backupCode",
      "password",
      "submit",
      "flash",
    ];
  }

  connect() {
    this.session = this.hasNicknameTarget
      ? {
          nickname: this.nicknameTarget.value,
          password: this.passwordTarget.value,
        }
      : {};

    if (this.hasOneTimeCodeTarget) {
      this.session.code = this.oneTimeCodeTarget.value;
      this.session.factor2 = true;
    }

    if (this.hasBackupCodeTarget) {
      this.session.code = this.backupCodeTarget.value;
      this.session.factor2 = true;
    }

    this.syncState();
  }

  updateCode(e) {
    this.session.code = e.target.value;
    this.syncState();
  }

  updateNickname(e) {
    this.session.nickname = e.target.value;
    this.syncState();
  }

  updatePassword(e) {
    this.session.password = e.target.value;
    this.syncState();
  }

  syncState() {
    this.submitTarget.classList.add("btn-accent");

    let flash;

    if (this.session.nickname && this.session.password) {
      this.submitTarget.disabled = false;

      flash = "continue";
    } else if (this.session.factor2) {
      const disabled = (this.session.code?.length || 0) < 6;
      this.submitTarget.disabled = disabled;

      flash = "enter-factor2";
    } else {
      this.submitTarget.disabled = !this.session.nickname;

      if (this.session.nickname) {
        flash = "enter-password";
      } else {
        flash = "enter-credentials";
      }
    }

    if (flash) {
      for (let el of this.flashTarget.querySelectorAll("[data-flash]")) {
        if (el.dataset.flash == flash) {
          el.classList.remove("hidden");
        } else {
          el.classList.add("hidden");
        }
      }
    }
  }
}
