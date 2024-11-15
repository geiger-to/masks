<script>
  import { CircleHelp as Icon } from "lucide-svelte";
  import Alert from "./Alert.svelte";
  import PromptHeader from "./PromptHeader.svelte";

  export let auth;
</script>

<PromptHeader
  heading="Invalid request..."
  client={auth.client}
  redirectUri={auth.redirectUri}
  class="mb-6"
/>

<Alert type="error" icon={Icon} class="mb-6">
  A <code>nonce</code> must be supplied in the authorization request.
</Alert>

<div class="flex items-center gap-6">
  <a href={auth.redirectUri} class="btn btn-error btn-lg text-lg"> go back </a>
</div>
