<script>
  import Time from "svelte-time";
  import Identicon from "./Identicon.svelte";
  import PasswordInput from "./PasswordInput.svelte";
  import EditableImage from "./EditableImage.svelte";
  import { Save, ChevronRight, X } from "lucide-svelte";

  export let actor;
  export let editing = false;
  export let isEditing = () => {};

  let form = { ...actor };
</script>

<div class="my-3 dark:bg-base-300 bg-base-200 rounded-lg p-3 px-3">
  <div class="flex items-center">
    <div class="grow flex items-center gap-3">
      <EditableImage
        endpoint="/upload/avatar"
        params={{ actor_id: actor.id }}
        src={actor?.avatar}
        name={actor?.identiconId}
        class="w-12 h-12"
        disabled={!editing}
      />

      <div>
        <div class="font-bold text-lg flex items-center gap-1.5">
          <div class="avatar">
            <div class="w-6 rounded-lg dark:bg-black bg-white">
              <Identicon id={actor.identiconId} />
            </div>
          </div>
          <span>
            {actor.nickname}
          </span>
        </div>

        <div class="text-xs">
          last login

          <span class="italic">
            {#if actor.lastLoginAt}
              <Time relative timestamp={actor.lastLoginAt} />
            {:else}
              never
            {/if}
          </span>
        </div>
      </div>
    </div>

    <div class="group join">
      {#if editing}
        <button disabled class="btn join-item btn-secondary"
          ><Save size="15" /> save</button
        >
      {:else}
        <button class="btn btn-ghost" on:click={() => isEditing({ actor })}
          ><ChevronRight /></button
        >
      {/if}
    </div>
  </div>

  {#if editing}
    <div class="divider my-1.5" />

    <div class="flex flex-col gap-1.5">
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
        <textarea class="w-full textarea text-base" bind:value={form.scopes} />
      </div>

      <div class="rounded-md pl-4 pr-1.5 py-3 flex items-baseline gap-3">
        <span class="label-text opacity-70 w-[60px]">created</span>
        <span class="italic text-base">
          <Time timestamp={actor.createdAt} />
        </span>
      </div>
    </div>
  {/if}
</div>
