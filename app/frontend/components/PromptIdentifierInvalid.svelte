<script>
  import { X } from "lucide-svelte";
  import PromptIdentify from "./PromptIdentify.svelte";
  import PromptAlert from "./PromptAlert.svelte";

  export let identifier;
</script>

<PromptLogin {...$$props} let:identifiers bind:identifier>
  <PromptAlert icon={X}>
    <p>Invalid {identifiers.join(" or ")}</p>
  </PromptAlert>
</PromptLogin>
