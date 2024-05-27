import { Controller } from "@hotwired/stimulus";
import Cookie from "js-cookie";

export default class extends Controller {
  static get targets() {
    return ["toggle"];
  }

  changedColorScheme(e) {
    if (this.toggleTarget) {
      this.toggleTarget.checked = e.matches;
    }
  }

  connect() {
    this.prefersColorScheme = window.matchMedia("(prefers-color-scheme: dark)");
    this.prefersColorScheme.addEventListener("change", this.changedColorScheme);
    this.prefersColorScheme.addListener(this.changedColorScheme);
  }

  toggle(e) {
    if (e.target.checked) {
      Cookie.set("default_theme", "dark", { sameSite: "strict" });
      document.documentElement.setAttribute(
        "data-theme",
        e.target.dataset.dark,
      );
      document.documentElement.classList.add("dark");
    } else {
      Cookie.set("default_theme", "light", { sameSite: "strict" });
      document.documentElement.setAttribute(
        "data-theme",
        e.target.dataset.light,
      );
      document.documentElement.classList.remove("dark");
    }
  }

  // toggleSettings(e) {
  //   this.settingsTarget.classList.toggle("hidden");

  //   e.preventDefault();
  //   e.stopPropagation();
  // }
}
