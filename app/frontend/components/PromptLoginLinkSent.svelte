<script>
  import { Send, MailSearch as Mail } from "lucide-svelte";
  import Pincode from "svelte-pincode/unstyled/Pincode.svelte";
  import PincodeInput from "svelte-pincode/unstyled/PincodeInput.svelte";
  import PromptHeader from "./PromptHeader.svelte";
  import PromptIdentifier from "./PromptIdentifier.svelte";
  import PromptContinue from "./PromptContinue.svelte";

  export let auth;
  export let identifier;
  export let loading;
  export let updates;

  let value;
  let complete;
  let error;

  $: if (complete) {
    updates({ code: value });
  }
</script>

<PromptHeader
  heading="Check your email..."
  client={auth.client}
  redirectUri={auth.redirectUri}
  class="mb-6"
/>

<div class="alert flex items-center gap-3 text-left rounded-lg mb-6">
  <div class="text-info mx-1.5">
    <Mail />
  </div>

  <p>
    A 6-character code was sent to your email. Enter it below to log in without
    a password...
  </p>
</div>

<PromptIdentifier bind:identifier {auth} class="mb-3" />

<div class="flex flex-col items-center mb-6">
  <Pincode
    bind:value
    bind:complete
    class="flex items-center join"
    type="numeric"
  >
    <PincodeInput
      placeholder="•"
      class="no-inc py-7 grow w-[100%] input input-bordered text-2xl px-3 text-center join-item"
    />
    <PincodeInput
      placeholder="•"
      class="no-inc py-7 grow w-[100%] input input-bordered text-2xl px-3 text-center join-item"
    />
    <PincodeInput
      placeholder="•"
      class="no-inc py-7 grow w-[100%] input input-bordered text-2xl px-3 text-center join-item"
    />
    <div class="md:px-1.5 opacity-75"></div>
    <PincodeInput
      placeholder="•"
      class="no-inc py-7 grow w-[100%] input input-bordered text-2xl px-3 text-center join-item"
    />
    <PincodeInput
      placeholder="•"
      class="no-inc py-7 grow w-[100%] input input-bordered text-2xl px-3 text-center join-item"
    />
    <PincodeInput
      placeholder="•"
      class="no-inc py-7 grow w-[100%] input input-bordered text-2xl px-3 text-center join-item"
    />
  </Pincode>
</div>

<div class="flex flex-col md:flex-row md:items-center md:gap-4">
  <PromptContinue
    label="continue"
    {loading}
    disabled={!complete}
    class={error ? "btn-error" : "btn-primary"}
    event="login-link:code"
  />

  <span class="opacity-75 text-lg ml-1.5 hidden md:flex"> or </span>

  <PromptContinue class="px-0 w-auto btn-link text-base-content">
    enter your password...
  </PromptContinue>
</div>
