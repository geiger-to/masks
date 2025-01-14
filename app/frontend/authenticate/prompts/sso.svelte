<script>
  import Icon from "@iconify/svelte";
  import { Info, X, Send, Mail } from "lucide-svelte";
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

  if (redirect) {
    redirectTimeout(() => {
      window.location.assign(redirect);
    }, 1000);
  }
</script>

<div class="animate-fade-in-1s">
  <SSOHeader {auth} {provider}>
    {#snippet heading()}
      Sending you to <a href={provider?.redirect} class="font-bold"
        >{provider?.name}</a
      >...
    {/snippet}
  </SSOHeader>

  <Alert type="neutral" icon={Info} class="mb-5 mx-6">
    <p class="text-lg m-1">
      You will be sent back here after you log in with your <b
        >{provider?.name}</b
      > credentials.
    </p>
  </Alert>

  <div class="text-center py-6">
    <span
      class="loading loading-spinner loading-lg mx-auto loading-dots opacity-50"
    ></span>
  </div>
</div>
