<script>
  import { Send, Mail } from "lucide-svelte";
  import PromptHeader from "./PromptHeader.svelte";
  import PromptIdentifier from "./PromptIdentifier.svelte";
  import PromptContinue from "./PromptContinue.svelte";
  import PasswordInput from "./PasswordInput.svelte";
  import { onDestroy } from "svelte";

  export let auth;
  export let identifier;
  export let password;
  export let loading;
  export let startOver;
  export let denied;
  export let loginLinks = auth?.settings?.email?.enabled;
  export let authorize;

  let seconds = 5;
  let continuing = false;
  let cancelled;

  let countdown = setInterval(() => {
    seconds = seconds - 1;

    if (seconds == 0) {
      continuing = true;
      clearInterval(countdown);
    }
  }, 1000);

  $: if (seconds == 0 && !cancelled) {
    setTimeout(() => {
      authorize({});
    }, 500);
  }

  let cancel = () => {
    clearInterval(countdown);
    seconds = 0;
    cancelled = true;
  };

  onDestroy(() => {
    if (countdown) {
      clearInterval(countdown);
    }
  });
</script>

<PromptHeader
  heading={cancelled
    ? "Press continue to log in..."
    : "Verifying your login code..."}
  client={auth.client}
/>
<PromptIdentifier
  identifier={auth?.actor?.loginEmail}
  alternate={auth?.actor?.nickname}
  {auth}
  class="my-6"
/>

<div class="flex flex-col md:flex-row md:items-center md:gap-4">
  <PromptContinue
    {loading}
    disabled={loading}
    class="btn-primary min-w-[150px]"
    event="login-link:code"
  >
    {!cancelled ? "continuing" : "continue"}

    {#if seconds > 0}
      <span class="opacity-75">in {seconds || ""}</span>
    {/if}
  </PromptContinue>

  {#if !cancelled}
    <span class="opacity-75 text-lg ml-1.5 hidden md:flex"> or </span>

    <button
      on:click|preventDefault|stopPropagation={cancel}
      class="px-0 !min-w-0 btn-link text-base-content"
    >
      cancel
    </button>
  {:else}
    <span class="opacity-75 max-w-[300px] ml-3 text-sm">
      Your login link will expire soon. If you don't recognize it, delete the
      original email and close this window.
    </span>
  {/if}
</div>
