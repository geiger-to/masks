import "./app.css";

import AppComponent from "../components/AppComponent.svelte";
import ManageApp from "../manage/App.svelte";

const target = document.getElementById("app");
const props = window.APP || {};

new AppComponent({
  target: target,
  props: { ...props, component: ManageApp },
});
