<script>
  import Alert from "@/components/Alert.svelte";
  import { Handshake as Icon } from "lucide-svelte";
  import PromptHeader from "./PromptHeader.svelte";
  import PromptIdentifier from "./PromptIdentifier.svelte";
  import PromptContinue from "./PromptContinue.svelte";
  import PasswordInput from "@/components/PasswordInput.svelte";
  import PromptBack from "./PromptBack.svelte";

  let { auth, authorize, loading = $bindable() } = $props();
</script>

<PromptHeader
  {auth}
  heading="Grant access"
  client={auth.client}
  suffix="?"
  class="mb-6"
/>

<PromptIdentifier {auth} class="mb-3" />

<div
  class="join join-vertical w-full mb-6 flex flex-col gap-0.5 bg-warn text-neutral-content"
>
  {#if !auth?.scopes?.length}
    <Alert type="warn" icon={Icon}>
      <b>{auth?.client?.name}</b> will be granted temporary access to verify
      your account. Personal details <i>will not be shared</i>.
    </Alert>
  {:else}
    <Alert type="warn" icon={Icon} class="join-item">
      <div>
        <b>{auth?.client?.name}</b> will have access to:
      </div>
    </Alert>

    <Alert type="warn" class="join-item !p-0">
      <div class="max-h-[333px] overflow-auto py-3 px-1.5 -m-[1px]">
        {#each auth?.scopes || [] as scope}
          {#if !scope.hidden}
            <div
              class="px-3 mr-[2px] text-sm flex items-center gap-3 my-3 overflow-hidden max-w-full"
            >
              <input
                type="checkbox"
                class="checkbox checkbox-xs checkbox-warning"
                checked
                disabled
              />

              <div class="truncate">
                {scope?.detail}
              </div>
            </div>
          {/if}
        {/each}
      </div>
    </Alert>
  {/if}
</div>

<div class="flex gap-3">
  <PromptContinue
    class="btn-success"
    label="approve"
    event="authorize"
    {authorize}
    {loading}
  />

  <PromptContinue
    class="btn-error"
    event="deny"
    label="deny"
    {loading}
    {authorize}
  />
</div>
