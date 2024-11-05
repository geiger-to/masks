<script>
  import { X, Send, Mail } from "lucide-svelte";
  import Alert from "./Alert.svelte";
  import PromptHeader from "./PromptHeader.svelte";
  import PromptIdentifier from "./PromptIdentifier.svelte";
  import PromptContinue from "./PromptContinue.svelte";
  import PasswordInput from "./PasswordInput.svelte";

  export let auth;
  export let loading;
  export let updates;

  let password;
  let valid;

  $: if (valid) {
    updates({ newPassword: password });
  } else {
    updates({ newPassword: null });
  }
</script>

<PromptHeader
  heading="Change your password..."
  client={auth.client}
  redirectUri={auth.redirectUri}
  prefix="before going to "
  suffix="?"
  class="mb-6"
/>

{#if auth?.warnings?.includes("expired-login-link")}
  <Alert icon={X} type="warn">Your 7-character code has expired.</Alert>
{/if}

<PromptIdentifier identifier={auth?.identifier} {auth} class="mb-3" />

<PasswordInput
  {auth}
  class="input-lg mb-6"
  placeholder="Your new password"
  bind:value={password}
  bind:valid
/>

<div class="flex flex-col md:flex-row md:items-center md:gap-4">
  <PromptContinue
    label="change"
    {loading}
    event="reset-password"
    disabled={!valid}
    class={"btn-primary"}
  />

  <span class="opacity-75 text-lg ml-1.5 hidden md:flex"> or </span>

  <PromptContinue
    event="reset-password:skip"
    class="btn-link px-0 text-base-content"
  >
    continue without changes...
  </PromptContinue>
</div>
