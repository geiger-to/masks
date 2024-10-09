<script>
  import PromptHeader from "./PromptHeader.svelte";
  import PromptContinue from "./PromptContinue.svelte";
  import { User } from "lucide-svelte";

  export let auth;
  export let nickname;
  export let password;
  export let loading;
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
    placeholder="enter your nickname..."
    type="text"
    bind:value={nickname}
  />
</label>

<PromptContinue {loading} disabled={!nickname} />
