import "./app.css";
import { Buffer } from "Buffer";

globalThis.Buffer = Buffer;

import AppComponent from "../components/AppComponent.svelte";
import AuthorizeSection from "../components/AuthorizeSection.svelte";
import { mount } from "svelte";

const target = document.getElementById("app");

mount(AppComponent, {
  target: target,
  props: { ...window.APP, component: AuthorizeSection },
});
