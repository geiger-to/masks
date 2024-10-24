<script>
  import PromptHeader from "./PromptHeader.svelte";
  import PromptContinue from "./PromptContinue.svelte";
  import { User } from "lucide-svelte";

  export let auth;
  export let identifier;
  export let password;
  export let loading;

  let identifiers = [];

  if (auth.settings?.nickname?.enabled) {
    identifiers.push("nickname");
  }

  if (auth.settings?.email?.enabled) {
    identifiers.push("email address");
  }
</script>

<PromptHeader
  heading="Authorize to continue..."
  client={auth.client}
  redirectUri={auth.redirectUri}
/>
<label class="input input-lg flex items-center gap-4 w-full mb-6">
  <User />
  <input
    class="w-full"
    placeholder={`enter your ${identifiers.join(" or ")}...`}
    type="text"
    bind:value={identifier}
  />
</label>

<PromptContinue {loading} disabled={!identifier} />
