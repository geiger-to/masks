<script>
  import Alert from "./Alert.svelte";
  import PromptHeader from "./PromptHeader.svelte";
  import PromptContinue from "./PromptContinue.svelte";
  import { AlertTriangle, User } from "lucide-svelte";

  export let auth;
  export let identifier;
  export let loading;
  export let updates;

  let identifiers = [];
  let value = identifier;
  let denied;

  $: denied = auth?.warnings?.includes("invalid-identifier");

  if (auth.settings?.nickname?.enabled) {
    identifiers.push("nickname");
  }

  if (auth.settings?.email?.enabled) {
    identifiers.push("email address");
  }

  $: if (value) {
    updates({ identifier: value });
    denied = false;
  }
</script>

<PromptHeader
  heading="Log in..."
  client={auth.client}
  redirectUri={auth.redirectUri}
  class="mb-6"
/>

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
  />
</label>

<div class="flex flex-col md:flex-row md:items-center md:gap-6">
  <PromptContinue
    {denied}
    {loading}
    disabled={!value}
    class={denied ? "btn-warning" : "btn-primary"}
    event="identifier:add"
  />
</div>
