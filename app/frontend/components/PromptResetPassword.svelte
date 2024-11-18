<script>
  import { run } from "svelte/legacy";

  import { X, Check, Send, Mail } from "lucide-svelte";
  import Alert from "./Alert.svelte";
  import PromptHeader from "./PromptHeader.svelte";
  import PromptIdentifier from "./PromptIdentifier.svelte";
  import PromptContinue from "./PromptContinue.svelte";
  import PasswordInput from "./PasswordInput.svelte";

  let { auth, loading, authorize } = $props();

  let password = $state();
  let valid = $state();
  let changed = $state();
  let denied = $state();

  run(() => {
    if (password) {
      denied = false;
    }
  });

  let changePassword = () => {
    if (!valid) {
      return;
    }

    authorize({
      event: "reset-password",
      updates: { newPassword: password },
    }).then((result) => {
      denied = result?.warnings?.includes("invalid-password");
      changed = result?.warnings?.includes("changed-password");
    });
  };
</script>

<PromptHeader
  heading={changed ? "Password changed!" : "Change your password..."}
  client={auth.client}
  redirectUri={auth.redirectUri}
  prefix={changed ? "Continue to " : "before going to "}
  suffix="?"
  class="mb-6"
/>

<PromptIdentifier identifier={auth?.identifier} {auth} class="mb-3" />

<PasswordInput
  {auth}
  class="input-lg mb-6"
  placeholder="Your new password"
  bind:value={password}
  bind:valid
  disabled={changed}
>
  {#snippet right()}
    <div class="flex items-center gap-3">
      {#if changed}
        <span class="text-success text-sm font-bold">changed</span>

        <Check class="text-success" size="20" />
      {/if}
    </div>
  {/snippet}
</PasswordInput>

<div class="flex flex-col md:flex-row md:items-center md:gap-4">
  <PromptContinue
    onClick={!changed ? changePassword : null}
    label={changed ? "continue" : "change"}
    {loading}
    {denied}
    disabled={!changed && !valid}
    class={changed ? "btn-success" : "btn-primary"}
  />

  {#if !changed}
    <span class="opacity-75 text-lg ml-1.5 hidden md:flex"> or </span>

    <PromptContinue
      event="reset-password:skip"
      class="btn-link px-0 text-base-content"
    >
      continue without changes...
    </PromptContinue>
  {/if}
</div>
