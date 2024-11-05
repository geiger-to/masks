<script>
  import { X, Send, Mail } from "lucide-svelte";
  import Alert from "./Alert.svelte";
  import PromptHeader from "./PromptHeader.svelte";
  import PromptIdentifier from "./PromptIdentifier.svelte";
  import PromptContinue from "./PromptContinue.svelte";
  import PasswordInput from "./PasswordInput.svelte";

  export let auth;
  export let identifier;
  export let loading;
  export let startOver;
  export let updates;
  export let setEvent;

  $: console.log(auth?.client);

  let allowLoginLinks;
  let allowPasswords;

  $: allowLoginLinks = auth?.client?.allowLoginLinks;
  $: allowPasswords = auth?.client?.allowPasswords;

  let valid = false;
  let password;
  let denied;

  $: if (auth?.warnings?.includes("invalid-credentials")) {
    denied = true;
  } else {
    denied = false;
  }

  $: if (password) {
    denied = false;
  }

  $: if (valid) {
    updates({ password });
  } else {
    updates({ password: null });
  }
</script>

<PromptHeader
  heading={allowPasswords ? "Enter your password..." : "Send a login link..."}
  client={auth.client}
  redirectUri={auth.redirectUri}
  class="mb-6"
/>

{#if auth?.warnings?.includes("expired-login-link")}
  <Alert icon={X} type="warn">Your 7-character code has expired.</Alert>
{/if}

<PromptIdentifier
  bind:identifier
  {auth}
  {startOver}
  class={allowPasswords ? "mb-3" : "mb-6"}
/>

{#if allowPasswords}
  <PasswordInput
    {auth}
    class="input-lg mb-6"
    placeholder="Your password"
    bind:value={password}
    bind:valid
  />

  <div class="flex flex-col md:flex-row md:items-center md:gap-4">
    <PromptContinue
      {loading}
      {denied}
      event={allowPasswords ? "password:check" : "login-link:authenticate"}
      disabled={allowPasswords && !valid}
      class={denied ? "btn-warning" : "btn-primary"}
    />

    {#if auth?.loginLink}
      <span class="opacity-75 text-lg ml-1.5 hidden md:flex"> or </span>

      <PromptContinue
        class="px-0 w-auto btn-link text-base-content"
        event="login-link:authenticate"
      >
        enter your login code...
      </PromptContinue>
    {:else if allowLoginLinks}
      <span class="opacity-75 text-lg ml-1.5 hidden md:flex"> or </span>

      <PromptContinue
        class="px-0 w-auto btn-link text-base-content"
        event="login-link:authenticate"
      >
        send an email to log in...
      </PromptContinue>
    {/if}
  </div>
{:else}
  <div class="flex flex-col md:flex-row md:items-center md:gap-4">
    <PromptContinue
      label={auth?.loginLink ? "enter your login code" : "email a login code"}
      {loading}
      {denied}
      event={"login-link:authenticate"}
      class={"btn-primary"}
    />
  </div>
{/if}
