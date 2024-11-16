<script>
  import { OctagonAlert as Icon } from "lucide-svelte";
  import Alert from "./Alert.svelte";
  import PromptLoading from "./PromptLoading.svelte";
  import PromptHeader from "./PromptHeader.svelte";
  import PromptBack from "./PromptBack.svelte";
  import PasswordInput from "./PasswordInput.svelte";
  import { onMount } from "svelte";
  import { redirectTimeout } from "../util";

  export let auth;

  let loading = true;

  onMount(() => {
    redirectTimeout(() => {
      window.location.reload();
    }, 150);

    setTimeout(() => {
      loading = false;
    }, 1000);
  });
</script>

{#if loading}
  <PromptLoading />
{:else}
  <PromptHeader
    heading="Session expired..."
    prefix="during access to "
    client={auth.client}
    class="mb-3"
  />

  <Alert type="error" icon={Icon} class="mb-3">
    Your session has expired. Refresh the page and try again to continue...
  </Alert>

  <button
    class="btn btn-lg"
    on:click|preventDefault|stopPropagation={() => window.location.reload()}
  >
    refresh the page
  </button>
{/if}
