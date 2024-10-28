<script>
  import PromptHeader from "./PromptHeader.svelte";
  import PromptIdentifier from "./PromptIdentifier.svelte";
  import PromptContinue from "./PromptContinue.svelte";
  import PasswordInput from "./PasswordInput.svelte";
  import PromptBack from "./PromptBack.svelte";

  export let auth;
  export let loading;
  export let startOver;
</script>

<PromptHeader
  heading="Allow access?"
  prefix=""
  suffix="will be able to:"
  client={auth.client}
  redirectUri={auth.redirectUri}
/>

<div class="join join-vertical w-full mb-6 flex flex-col gap-0.5">
  <div class="bg-base-100 p-3 px-6 rounded-lg join-item">
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
  <PromptIdentifier avatarOnly {auth} {startOver} class="mb-3" />

  <PromptContinue
    class="btn-success"
    label="approve"
    data-event="approve"
    {loading}
  />

  <PromptContinue class="btn-error" data-event="deny" label="deny" {loading} />
</div>
