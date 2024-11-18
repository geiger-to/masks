<script>
  import Alert from "./Alert.svelte";
  import PromptHeader from "./PromptHeader.svelte";
  import PromptContinue from "./PromptContinue.svelte";
  import { AlertTriangle, User } from "lucide-svelte";

  let { auth } = $props();

  let denied = $derived(auth?.warnings?.includes("invalid-device"));
</script>

<PromptHeader
  heading={denied ? "Unable to continue..." : "Update your device..."}
  client={auth.client}
  redirectUri={auth.redirectUri}
  class="mb-6"
/>

{#if denied}
  <Alert type="warn" icon={AlertTriangle}>
    Your device is not supported by <b>{auth?.settings?.name}</b>. You must use
    a more recent device to continue.
  </Alert>
{/if}
