<script>
  import Alert from "./Alert.svelte";
  import { Handshake as Icon } from "lucide-svelte";
  import PromptHeader from "./PromptHeader.svelte";
  import PromptIdentifier from "./PromptIdentifier.svelte";
  import PromptContinue from "./PromptContinue.svelte";
  import PasswordInput from "./PasswordInput.svelte";
  import PromptBack from "./PromptBack.svelte";

  export let auth;
  export let loading;

  let details;

  $: details = auth?.scopes
    ?.map((scope) => {
      if (!scope.hidden) {
        return scope.detail;
      }
    })
    .filter(Boolean);
</script>

<PromptHeader
  {auth}
  heading="Confirm access"
  client={auth.client}
  class="mb-6"
/>

<PromptIdentifier {auth} class="mb-3" />

<div class="join join-vertical w-full mb-6 flex flex-col gap-0.5 bg-base-100">
  <Alert type="warn" icon={Icon} class="join-item">
    <b>{auth?.client?.name}</b> will be able to:
  </Alert>

  {#each auth?.scopes as scope}{/each}

  <div class="bg-base-200 p-3 px-6 rounded-lg join-item">
    Identify your account
  </div>

  <div class="bg-base-100 p-3 px-6 rounded-lg join-item">
    See your primary email address
  </div>

  <div class="bg-base-100 p-3 px-6 rounded-lg join-item">
    See your profile, including your name and address
  </div>
</div>

<div class="flex gap-3">
  <PromptContinue
    class="btn-success"
    label="approve"
    data-event="approve"
    {loading}
  />

  <PromptContinue class="btn-error" data-event="deny" label="deny" {loading} />
</div>
