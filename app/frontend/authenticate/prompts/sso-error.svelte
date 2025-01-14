<script>
  import {
    Link,
    Unlink,
    XCircle,
    X,
    AlertTriangle,
    Send,
    Mail,
  } from "lucide-svelte";
  import Alert from "@/components/Alert.svelte";
  import SSOHeader from "./SSOHeader.svelte";
  import PromptHeader from "./PromptHeader.svelte";
  import PromptIdentifier from "./PromptIdentifier.svelte";
  import PromptContinue from "./PromptContinue.svelte";
  import PasswordInput from "@/components/PasswordInput.svelte";
  import { redirectTimeout } from "@/util.js";

  let { settings, backend } = $props();

  let errors = {
    "invalid-sso": "Your single sign-on request is expired or invalid.",
  };
</script>

<div class="animate-fade-in-1s">
  <SSOHeader provider={backend?.provider}>
    {#snippet heading()}
      <div class="flex items-center gap-3">
        {#if backend.provider}
          <p>Log in with <b>{backend.provider.name}</b> failed...</p>
        {:else}
          Log in failed....
        {/if}
      </div>
    {/snippet}

    {#snippet alert()}
      <Alert
        type="error"
        icon={AlertTriangle}
        class="text-center"
        errors={[errors[backend.error] || backend.error]}
      />
    {/snippet}
  </SSOHeader>

  {#if backend.origin}
    <a href={backend.origin} class="btn btn-lg"> go back </a>
  {:else if settings?.theme?.url}
    <a href={settings?.theme?.url} class="btn btn-lg"> go home </a>
  {/if}
</div>
