<script>
  import { ShieldX } from "lucide-svelte";
  import PromptHeader from "./PromptHeader.svelte";
  import PromptNickname from "./PromptNickname.svelte";
  import PromptContinue from "./PromptContinue.svelte";
  import PromptAlert from "./PromptAlert.svelte";
  import PasswordInput from "./PasswordInput.svelte";

  export let auth;
  export let nickname;
  export let password;
  export let loading;
  export let startOver;
</script>

<PromptHeader
  heading="Enter your password..."
  client={auth.client}
  redirectUri={auth.redirectUri}
/>

<PromptNickname {nickname} avatar={auth.avatar} {startOver} class="mb-3" />
<PasswordInput
  class="input-lg mb-6"
  placeholder="enter your password..."
  bind:value={password}
/>

<div class="flex items-center gap-6">
  <PromptContinue {loading} disabled={!nickname} />

  <PromptAlert icon={ShieldX}>
    <p>Invalid credentials.<br />Try again...</p>
  </PromptAlert>
</div>
