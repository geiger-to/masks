<script>
  import Alert from "@/components/Alert.svelte";
  import PromptHeader from "./PromptHeader.svelte";
  import PromptContinue from "./PromptContinue.svelte";
  import { Unlink, X, ArrowRight, AlertTriangle, User } from "lucide-svelte";
  import { iconifyProvider } from "@/util.js";

  let { auth, authorize, identifier, loading = $bindable() } = $props();

  let identifiers = [];
  let value = $state(identifier);
  let denied = $state();
  let sso = $state();
  let ssoAllowed = $state();

  sso = auth?.extras?.sso;
  ssoAllowed = !sso && auth?.providers?.length;

  if (auth.settings?.nicknames?.enabled) {
    identifiers.push("nickname");
  }

  if (auth.settings?.emails?.enabled) {
    identifiers.push("email address");
  }

  let onsubmit = (e) => {
    e.preventDefault();
    e.stopPropagation();

    authorize({ event: "identify", updates: { identifier: value } });
  };

  $effect(() => {
    denied = auth?.warnings?.includes("invalid-identifier");
  });
</script>

<PromptHeader
  heading="Log in..."
  client={auth.client}
  redirectUri={auth.redirectUri}
  class="mb-6"
/>

{#if sso}
  <Alert type="info" class="mb-6">
    <div class="flex items-start gap-3">
      <p>
        Your <b>{sso.provider.name}</b> account can be linked once you successfully
        log in...
      </p>

      <div>
        <PromptContinue
          confirm={`Are you sure you want to cancel linking your ${sso.provider.name} account?`}
          label={null}
          icon={X}
          class="!btn-xs btn-info !min-w-0 whitespace-nowrap"
          type="submit"
          event={"sso:reset"}
          {authorize}
        >
          {#snippet children()}
            Cancel link
          {/snippet}
        </PromptContinue>
      </div>
    </div>
  </Alert>
{/if}

<form action="#" {onsubmit}>
  <label
    class={[
      "input input-lg input-bordered flex items-center gap-4 w-full mb-6",
      denied ? "input-warning" : "",
    ].join(" ")}
  >
    {#if denied}
      <details class="dropdown ml-0.5">
        <summary class="cursor-pointer">
          <AlertTriangle class="text-warning" />
        </summary>

        <div
          class="dropdown-content text-warning-content bg-warning text-xs rounded-lg shadow-xl p-1.5 px-3 w-[150px] mt-1.5"
        >
          Invalid {identifiers.join(" or ")}
        </div>
      </details>
    {:else}
      <User class="hidden md:inline" />
    {/if}

    <input
      class="w-full placeholder:text-sm md:placeholder:text-base"
      placeholder={`Enter your ${identifiers.join(" or ")}...`}
      type="text"
      bind:value
      oninput={() => (denied = false)}
    />

    {#if ssoAllowed}
      <PromptContinue
        type="submit"
        {loading}
        disabled={!value}
        class={`-mr-6 !min-w-0 rounded-l-none ${denied ? "btn-warning" : "btn-primary"}`}
      >
        {#snippet children({ denied })}
          {#if denied}
            <X />
          {:else}
            <ArrowRight />
          {/if}
        {/snippet}
      </PromptContinue>
    {/if}
  </label>

  {#if ssoAllowed}
    <div class="divider my-6"><span class="opacity-50">or</span></div>

    <div class="flex flex-col gap-3">
      {#each auth.providers as provider}
        <PromptContinue
          label={`Log in with ${provider.name}`}
          class="w-full flex items-center gap-3 btn-outline dark:fill-white fill-black"
          iconify={iconifyProvider(provider)}
          iconClass="opacity-75"
          type="submit"
          event={"sso:request"}
          updates={{ provider: provider.id, origin: window.location.href }}
          {authorize}
        />
      {/each}
    </div>
  {:else}
    <PromptContinue
      type="submit"
      {denied}
      {loading}
      disabled={!value}
      class={`-mr-6 !min-w-0 ${denied ? "btn-warning" : "btn-primary"}`}
    />
  {/if}
</form>
