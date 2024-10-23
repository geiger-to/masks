<script>
  import { X } from "lucide-svelte";
  import PromptHeader from "./PromptHeader.svelte";
  import PromptContinue from "./PromptContinue.svelte";
  import PasswordInput from "./PasswordInput.svelte";
  import PromptBack from "./PromptBack.svelte";

  export let auth;
  export let password;
  export let startOver;
</script>

<PromptHeader
  heading="Invalid request"
  client={auth.client}
  redirectUri={auth.redirectUri}
/>

<div class="alert flex items-center gap-3 rounded-lg mb-6">
  <X class="text-error" />
  <p class="text-xl">
    {auth.errorMessage}
  </p>
</div>

<PromptBack />
