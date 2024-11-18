import "./app.css";
import { Buffer } from "Buffer";

globalThis.Buffer = Buffer;

import AppComponent from "../components/AppComponent.svelte";
import AuthorizeSection from "../components/AuthorizeSection.svelte";

const target = document.getElementById("app");

new AppComponent({
  target: target,
  props: { ...window.APP, component: AuthorizeSection },
});
