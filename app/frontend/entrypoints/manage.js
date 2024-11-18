import "./app.css";

import AppComponent from "../components/AppComponent.svelte";
import ManageApp from "../manage/App.svelte";
import { mount } from "svelte";

const target = document.getElementById("app");
const props = window.APP || {};

mount(AppComponent, {
  target: target,
  props: { ...props, component: ManageApp },
});
