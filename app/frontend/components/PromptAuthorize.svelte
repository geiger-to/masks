<script>
  import PromptHeader from "./PromptHeader.svelte";
  import PromptNickname from "./PromptNickname.svelte";
  import PromptContinue from "./PromptContinue.svelte";
  import PasswordInput from "./PasswordInput.svelte";
  import PromptBack from "./PromptBack.svelte";

  export let auth;
  export let nickname;
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
  <PromptNickname
    avatarOnly
    {nickname}
    avatar={auth.avatar}
    {startOver}
    class="mb-3"
  />

  <PromptContinue
    class="btn-success"
    label="approve"
    data-approve="true"
    {loading}
  />

  <PromptContinue class="btn-error" data-deny="true" label="deny" {loading} />
</div>
