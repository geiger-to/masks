<script>
  import PromptHeader from "./PromptHeader.svelte";
  import PromptNickname from "./PromptNickname.svelte";
  import PromptContinue from "./PromptContinue.svelte";
  import PasswordInput from "./PasswordInput.svelte";

  export let auth;
  export let nickname;
  export let password;
  export let startOver;
</script>

<PromptHeader
  heading="Access granted..."
  client={auth.client}
  redirectUri={auth.redirectUri}
/>
<PromptNickname {nickname} avatar={auth.avatar} class="mb-6" />

<PromptContinue loading />
