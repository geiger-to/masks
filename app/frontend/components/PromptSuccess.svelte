<script>
  import { ShieldCheck as Check } from "lucide-svelte";
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
  class="mb-6"
/>

<PromptIdentifier
  {identifier}
  {auth}
  class="mb-6 pr-3 bg-success text-success-content"
>
  <div class="rounded-full w-12 h-12 bg-success flex items-center">
    <Check size="30" class="mx-auto" />
  </div>
</PromptIdentifier>

<PromptContinue loading />
