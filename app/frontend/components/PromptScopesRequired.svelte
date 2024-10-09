<script>
  import { X } from "lucide-svelte";
  import PromptHeader from "./PromptHeader.svelte";
  import PromptAlert from "./PromptAlert.svelte";
  import PromptNickname from "./PromptNickname.svelte";
  import PromptContinue from "./PromptContinue.svelte";
  import PasswordInput from "./PasswordInput.svelte";

  export let auth;
  export let nickname;
  export let password;
  export let startOver;
</script>

<PromptHeader
  heading="Access denied..."
  client={auth.client}
  redirectUri={auth.redirectUri}
/>

<PromptNickname {nickname} avatar={auth.avatar} {startOver} class="mb-6" />

<div class="flex items-center gap-6">
  <button
    class="btn btn-error btn-lg text-lg"
    on:click|stopPropagation|preventDefault={startOver}
  >
    start over
  </button>

  <PromptAlert>You do not have permission to go further.</PromptAlert>
</div>
