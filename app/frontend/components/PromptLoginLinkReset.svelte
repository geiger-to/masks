<script>
  import { Send, Mail } from "lucide-svelte";
  import PromptHeader from "./PromptHeader.svelte";
  import PromptAlert from "./PromptAlert.svelte";
  import PromptIdentifier from "./PromptIdentifier.svelte";
  import PromptContinue from "./PromptContinue.svelte";
  import PasswordInput from "./PasswordInput.svelte";

  export let auth;
  export let identifier;
  export let loading;
  export let startOver;
  export let denied;
  export let loginLinks = auth?.settings?.email?.enabled;
  export let updates;

  let newPassword;
  let validPassword;
</script>

<div class="flex flex-col gap-6">
  <PromptHeader heading="Reset your password..." />

  <PromptIdentifier
    identifier={auth?.actor?.loginEmail}
    alternate={auth?.actor?.nickname}
    {auth}
    class="mb-3"
  />
</div>

<PasswordInput
  {auth}
  class="input-lg mb-6"
  placeholder="Enter a new password"
  bind:value={newPassword}
  bind:valid={validPassword}
  onChange={() => updates({ password: newPassword })}
/>

<div class="flex flex-col md:flex-row md:items-center md:gap-4">
  <PromptContinue
    label="save"
    {loading}
    disabled={!validPassword}
    class={"btn-primary"}
    event="reset-password"
  />
  <span class="opacity-75 text-lg ml-1.5 hidden md:flex"> or </span>

  <PromptContinue
    class="px-0 !min-w-0 btn-link text-base-content"
    event="cancel-reset-password"
  >
    cancel
  </PromptContinue>
</div>
