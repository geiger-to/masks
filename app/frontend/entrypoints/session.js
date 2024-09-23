import SessionComponent from "../components/SessionComponent.svelte";

const target = document.getElementById("session");

new SessionComponent({
  target: target,
});
