<script>
  import PromptHeader from "./PromptHeader.svelte";
  import PromptIdentifier from "./PromptIdentifier.svelte";
  import PromptContinue from "./PromptContinue.svelte";
  import PasswordInput from "./PasswordInput.svelte";

  export let auth;
  export let identifier;
  export let password;
  export let loading;
  export let startOver;
</script>

<PromptHeader
  heading="Enter your password..."
  client={auth.client}
  redirectUri={auth.redirectUri}
/>
<PromptIdentifier {identifier} {auth} {startOver} class="mb-3" />
<PasswordInput
  class="input-lg mb-6"
  placeholder="your password..."
  bind:value={password}
/>

<PromptContinue {loading} disabled={!identifier} />
