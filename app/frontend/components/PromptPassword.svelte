<script>
  import { Send, Mail } from "lucide-svelte";
  import PromptHeader from "./PromptHeader.svelte";
  import PromptIdentifier from "./PromptIdentifier.svelte";
  import PromptContinue from "./PromptContinue.svelte";
  import PasswordInput from "./PasswordInput.svelte";

  export let auth;
  export let identifier;
  export let password;
  export let loading;
  export let startOver;
  export let denied;
  export let loginLinks = auth?.settings?.email?.enabled;

  let label;
  let min;
  let max;
  let valid = false;
  let placeholder = "your password";

  $: if (auth?.errorCode == "invalid_credentials") {
    label = "try again";
  } else {
    label = "continue";
  }

  $: min = auth?.settings?.passwords?.min;
  $: max = auth?.settings?.passwords?.max;

  $: if (min && max) {
    valid = password && password.length >= min && password.length <= max;
    placeholder = `${min} to ${max} characters...`;
  } else {
    valid = true;
  }
</script>

<PromptHeader
  heading="Enter your password..."
  client={auth.client}
  redirectUri={auth.redirectUri}
/>
<PromptIdentifier bind:identifier {auth} {startOver} class="mb-3" />

<PasswordInput
  minlength={min}
  maxlength={max}
  class="input-lg mb-6"
  {placeholder}
  bind:value={password}
/>

<div class="flex flex-col md:flex-row md:items-center md:gap-4">
  <PromptContinue
    {label}
    {loading}
    {denied}
    disabled={!valid}
    class={denied ? "btn-error" : "btn-primary"}
  />

  {#if loginLinks}
    <span class="opacity-75 text-lg ml-1.5 hidden md:flex"> or </span>

    <PromptContinue
      class="px-0 w-auto btn-link text-base-content"
      event="login-link"
    >
      send an email to log in...
    </PromptContinue>
  {/if}

  <slot />
</div>
