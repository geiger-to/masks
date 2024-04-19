import { themeChange } from "theme-change";
import { Application } from "@hotwired/stimulus";

// Enable changing themes
themeChange();

const application = Application.start();

// Configure Stimulus development experience
application.debug = true;
window.Stimulus = application;

export { application };
