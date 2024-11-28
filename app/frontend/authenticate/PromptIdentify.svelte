<script>
  import Alert from "@/components/Alert.svelte";
  import PromptHeader from "./PromptHeader.svelte";
  import PromptContinue from "./PromptContinue.svelte";
  import { AlertTriangle, User } from "lucide-svelte";

  let { auth, authorize, identifier, loading = $bindable() } = $props();

  let identifiers = [];
  let value = $state(identifier);
  let denied = $state();

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
      placeholder={`Your ${identifiers.join(" or ")}...`}
      type="text"
      bind:value
      oninput={() => (denied = false)}
    />
  </label>

  <div class="flex flex-col md:flex-row md:items-center md:gap-6">
    <PromptContinue
      type="submit"
      {denied}
      {loading}
      disabled={!value}
      class={denied ? "btn-warning" : "btn-primary"}
    />
  </div>
</form>
