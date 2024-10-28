<script>
  import Identicon from "./Identicon.svelte";
  import { RotateCcw } from "lucide-svelte";

  export let auth;
  export let startOver = null;
  export let avatarOnly;
  export let identifier;

  let { avatar, identiconId } = auth;
</script>

{#if identifier || auth?.identifier}
  <div
    class={[
      "flex items-center gap-3 bg-base-100  shadow font-bold",
      "rounded-lg shadow",
      avatarOnly ? "" : "py-2 px-3",
      $$props.class,
    ].join(" ")}
  >
    <div
      class={["avatar relative", startOver ? "cursor-pointer" : ""].join(" ")}
      role="button"
      on:click|preventDefault|stopPropagation={startOver}
    >
      <div
        class={`${avatarOnly ? "w-10" : "w-10"} rounded-lg bg-black m-1 group`}
      >
        <div class={startOver ? "group-hover:hidden" : ""}>
          {#if avatar}
            <img src={avatar} class="object-cover" />
          {:else}
            <Identicon id={identiconId} />
          {/if}
        </div>

        {#if startOver}
          <div
            class="group-hover:absolute bg-black flex items-center justify-center left-0 right-0 top-0 bottom-0 m-1 rounded-lg"
          >
            <RotateCcw />
          </div>
        {/if}
      </div>
    </div>

    {#if !avatarOnly}
      <div class="text-xl grow mr-3">
        {identifier || auth.identifier}
      </div>
    {/if}
  </div>
{:else}
  <div
    class={[
      "flex items-center gap-3 bg-neutral text-neutral-content shadow font-bold opacity-70",
      "rounded-lg shadow",
      avatarOnly ? "" : "py-2 px-3",
      $$props.class,
    ].join(" ")}
  >
    <div class={["avatar relative"].join(" ")}>
      <div
        class={`${avatarOnly ? "w-14" : "w-12"} rounded-lg bg-base-300 m-1 group`}
      ></div>
    </div>

    {#if !avatarOnly}
      <div class="text-xl grow mr-3">
        <div class="skeleton rounded-lg h-10 w-1/2"></div>
      </div>
    {/if}
  </div>
{/if}
