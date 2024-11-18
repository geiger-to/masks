<script>
  import { OctagonAlert as Icon } from "lucide-svelte";
  import Alert from "./Alert.svelte";
  import PromptHeader from "./PromptHeader.svelte";
  import PromptIdentifier from "./PromptIdentifier.svelte";

  let { auth } = $props();
</script>

<PromptHeader
  heading="Access denied..."
  client={auth.client}
  redirectUri={auth.redirectUri}
  class="mb-6"
/>

<Alert type="error" icon={Icon} class="mb-3">
  You do not have permission to continue. Contact an administrator for access.
</Alert>

<PromptIdentifier {auth} class="mb-6" />

<div class="flex items-center gap-6">
  <a href={auth.redirectUri} class="btn btn-error btn-lg text-lg"> go back </a>
</div>
