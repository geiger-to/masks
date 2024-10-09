import "./app.css";

import AppComponent from "../components/AppComponent.svelte";

const target = document.getElementById("app");

new AppComponent({
  target: target,
  props: window.APP,
});
