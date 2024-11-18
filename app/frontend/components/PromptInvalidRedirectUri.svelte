<script>
  import { CircleHelp as Icon } from "lucide-svelte";
  import Alert from "./Alert.svelte";
  import PromptHeader from "./PromptHeader.svelte";
  import PromptBack from "./PromptBack.svelte";

  let { auth } = $props();
</script>

<PromptHeader
  heading="Invalid request..."
  client={auth.client}
  redirectUri={auth.redirectUri}
  class="mb-6"
/>

<Alert type="error" icon={Icon} class="mb-6">
  The supplied <code>redirect_uri</code> cannot be used.
</Alert>

<PromptBack />
