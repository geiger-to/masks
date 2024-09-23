import ManageComponent from "../components/ManageComponent.svelte";
import "./manage.css"

const target = document.getElementById("manage");

new ManageComponent({
  target: target,
});
