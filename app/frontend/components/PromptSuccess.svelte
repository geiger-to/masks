<script>
  import PromptHeader from "./PromptHeader.svelte";
  import PromptIdentifier from "./PromptIdentifier.svelte";
  import PromptContinue from "./PromptContinue.svelte";
  import PasswordInput from "./PasswordInput.svelte";

  export let auth;
  export let identifier;
  export let password;
  export let startOver;
</script>

<PromptHeader
  heading="Access granted..."
  client={auth.client}
  redirectUri={auth.redirectUri}
/>
<PromptIdentifier {identifier} {auth} class="mb-6" />

<PromptContinue loading />
