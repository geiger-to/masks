import "./app.css";

import App from "@/App.svelte";
import Page from "@/authenticate/Page.svelte";
import { mount } from "svelte";

const target = document.getElementById("app");

mount(App, {
  target: target,
  props: { ...window.APP, Component: Page },
});
