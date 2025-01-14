<script>
  import { Link, Unlink, X, Send, Mail } from "lucide-svelte";
  import Alert from "@/components/Alert.svelte";
  import SSOHeader from "./SSOHeader.svelte";
  import PromptHeader from "./PromptHeader.svelte";
  import PromptIdentifier from "./PromptIdentifier.svelte";
  import PromptContinue from "./PromptContinue.svelte";
  import PasswordInput from "@/components/PasswordInput.svelte";
  import { redirectTimeout } from "@/util.js";

  let {
    auth,
    authorize,
    identifier,
    loading = $bindable(),
    startOver,
  } = $props();

  let { provider, redirect, phase } = auth.extras;
</script>

<div class="animate-fade-in-1s">
  <SSOHeader {auth} {provider}>
    {#snippet heading()}
      {#if auth.trusted}
        Link your <b class="font-bold">{provider?.name}</b> account?
      {:else}
        Your
        <b class="font-bold">{provider?.name}</b> account is not linked...
      {/if}
    {/snippet}
  </SSOHeader>

  <Alert type="info" icon={Link} class="mb-10 md:mx-6">
    <p class="text-lg m-1">
      You can log in using your existing credentials to link accounts, or try a
      different way to log in.
    </p>
  </Alert>

  <div class="flex items-center gap-3 w-full justify-center pb-8">
    <PromptContinue
      label={`Log in`}
      type="submit"
      class="btn-info"
      event={"sso:login"}
      {authorize}
    />

    <PromptContinue
      confirm="Are you sure you want to start over?"
      label={`Start over`}
      iconClass="opacity-75"
      type="submit"
      event={"sso:reset"}
      {authorize}
    />
  </div>
</div>
