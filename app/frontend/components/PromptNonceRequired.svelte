<script>
  import { X } from "lucide-svelte";
  import PromptHeader from "./PromptHeader.svelte";
  import PromptNickname from "./PromptNickname.svelte";
  import PromptBack from "./PromptBack.svelte";
  import PasswordInput from "./PasswordInput.svelte";

  export let auth;
  export let nickname;
  export let password;
  export let startOver;
</script>

<PromptHeader
  heading="Invalid request"
  client={auth.client}
  redirectUri={auth.redirectUri}
/>

<div class="alert flex items-center gap-3 rounded-lg mb-6 text-left">
  <X class="text-error" />
  <p class="text-xl">
    A <code>nonce</code> must be supplied.
  </p>
</div>

<PromptBack />
