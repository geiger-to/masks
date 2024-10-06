<script>
  import Time from "svelte-time";
  import Identicon from "./Identicon.svelte";
  import PasswordInput from "./PasswordInput.svelte";
  import { Save, ChevronDown, X } from "lucide-svelte";

  export let actor;
  export let editing = false;

  let form = { ...actor };
  let ICON_TYPES = {
    internal: "",
    public: "",
    confidential: "",
  };
</script>

<div class="my-3 dark:bg-base-300 bg-base-200 rounded-lg p-3 px-3">
  <button
    tabindex="0"
    class="flex items-center cursor-pointer"
    on:click|preventDefault={() => (editing = !editing)}
  >
    <div class="grow flex items-center gap-3">
      <div class="avatar">
        <div class="w-12 rounded-lg dark:bg-black bg-white">
          <Identicon nickname={actor.nickname} />
        </div>
      </div>

      <div>
        <div class="font-bold text-lg">
          {actor.nickname}
        </div>

        <div class="text-xs">
          last login

          <span class="italic">
            {#if actor.lastLoginAt}
              <Time timestamp={actor.lastLoginAt} />
            {:else}
              never
            {/if}
          </span>
        </div>
      </div>
    </div>

    <div class="flex group join">
      {#if editing}
        <button disabled class="btn join-item btn-sm btn-secondary"
          ><Save size="15" /> save</button
        >
        <button class="btn join-item btn-sm btn-error"><X size="20" /></button>
      {:else}
        <button class="btn btn-sm btn-ghost"><ChevronDown /></button>
      {/if}
    </div>
  </button>

  {#if editing}
    <div class="divider my-1.5" />

    <div class="flex flex-col gap-1.5">
      <div class="rounded-md pl-4 pr-1.5 py-3 flex items-baseline gap-3">
        <span class="label-text opacity-70 w-[60px]">created</span>
        <span class="italic text-base">
          <Time timestamp={actor.createdAt} />
        </span>
      </div>

      <PasswordInput
        label="password"
        placeholder="enter a new password..."
        bind:value={form.newPassword}
      >
        <div class="text-xs" slot="right">
          <span class="italic">
            {#if actor.changedPasswordAt}
              changed <Time timestamp={actor.changedPasswordAt} />
            {:else if actor.password}
              never changed
            {:else}
              not set
            {/if}
          </span>
        </div>
      </PasswordInput>

      <div
        class="rounded-md pl-4 pr-1.5 py-1.5 flex items-baseline gap-3 input
        input-bordered max-h-full h-auto"
      >
        <span class="label-text opacity-70 w-[60px]">scopes</span>
        <textarea class="w-full textarea text-base">{actor.scopes}</textarea>
      </div>
    </div>
  {/if}
</div>
