import ManageComponent from "../components/ManageComponent.svelte";

const target = document.getElementById("manage");

new ManageComponent({
  target: target,
});
