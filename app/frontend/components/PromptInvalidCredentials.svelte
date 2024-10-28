<script>
  import _ from "lodash-es";
  import PromptPassword from "./PromptPassword.svelte";

  export let identifier;
  export let password;
  export let auth;

  let requestId;
  let timeout;
  let denied;

  $: if (requestId != auth?.requestId) {
    denied = true;
    clearTimeout(timeout);
    timeout = setTimeout(() => {
      denied = false;
    }, 1000);

    requestId = auth?.requestId;
  }
</script>

{#key requestId}
  <PromptPassword
    {auth}
    {denied}
    {...$$props}
    bind:password
    bind:identifier
  ></PromptPassword>
{/key}
