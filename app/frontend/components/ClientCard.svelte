<script>
  import { Save, ChevronDown, X } from "lucide-svelte";
  import PasswordInput from "./PasswordInput.svelte";

  export let client;
  export let editing = false;

  let avatarPlaceholder = client?.name
    ?.split(" ")
    .map((word) => word[0])
    .join("")
    .toUpperCase()
    .slice(0, 2);

  let form = { ...client };
  let ICON_TYPES = {
    internal: "",
    public: "",
    confidential: "",
  };
</script>

<div
  class="my-3 dark:bg-base-300 bg-base-200 rounded-lg p-3 px-3 text-base-content"
>
  <div
    class="flex items-center pl-1.5 cursor-pointer gap-3"
    on:click|preventDefault={() => (editing = !editing)}
  >
    <div class="avatar placeholder">
      <div class="bg-neutral text-neutral-content w-12 rounded-lg">
        <span>{avatarPlaceholder}</span>
      </div>
    </div>

    <div class="grow">
      <h2 class="font-bold">{client.name}</h2>

      <div class="flex items-baseline gap-3">
        <span class="text-sm font-mono">{client.id}</span>
        <span class="text-xs italic">{client.type}</span>
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
  </div>

  {#if editing}
    <div class="divider my-1.5" />

    <div class="flex flex-col gap-1.5 mb-3">
      <label class="input input-bordered flex items-center gap-3">
        <span class="label-text opacity-70 w-[60px]">name</span>
        <input
          type="text"
          class="grow ml-3"
          placeholder="required"
          bind:value={form.name}
        />
      </label>

      <label class="input input-bordered flex items-center gap-3">
        <span class="label-text opacity-70 w-[60px]">identifier</span>
        <input
          type="text"
          class="grow ml-3"
          placeholder="required"
          bind:value={form.id}
        />
      </label>

      <PasswordInput label="secret" bind:value={form.secret} />

      <div
        class="input input-bordered rounded-md pl-4 pr-1.5 py-1.5 flex items-center gap-3"
      >
        <span class="label-text opacity-70 w-[60px]">type</span>
        <select class="select select-sm w-full ml-1.5" bind:value={form.type}>
          <option selected={form.type == "internal"}>internal</option>
          <option selected={form.type == "confidential"}>confidential</option>
          <option selected={form.type == "public"}>public</option>
        </select>
      </div>

      <div
        class="input input-bordered rounded-md h-auto pl-4 pr-1.5 py-1.5 flex items-baseline gap-3"
      >
        <span class="label-text opacity-70 w-[60px]">redirect uris</span>
        <textarea class="w-full textarea"
          >{client.redirectUris.join("\n")}</textarea
        >
      </div>

      <div
        class="input input-bordered h-auto rounded-md pl-4 pr-1.5 py-1.5 flex items-baseline gap-3"
      >
        <span class="label-text opacity-70 w-[60px]">scopes</span>
        <textarea class="w-full textarea">{client.scopes.join(" ")}</textarea>
      </div>
    </div>
  {/if}
</div>
