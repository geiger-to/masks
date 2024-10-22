<script>
  import Identicon from "./Identicon.svelte";
  import { RotateCcw } from "lucide-svelte";

  export let avatar;
  export let nickname;
  export let startOver = null;
  export let avatarOnly;
</script>

{#if nickname}
  <div
    class={[
      "flex items-center gap-3 bg-neutral text-neutral-content shadow font-bold",
      "rounded-lg shadow",
      avatarOnly ? "" : "py-2 px-3",
      $$props.class,
    ].join(" ")}
  >
    <div
      class={["avatar relative", avatarOnly ? "cursor-pointer" : ""].join(" ")}
      role="button"
      on:click|preventDefault|stopPropagation={startOver}
    >
      <div
        class={`${avatarOnly ? "w-14" : "w-12"} rounded-lg bg-black m-1 group`}
      >
        <div class="group-hover:hidden">
          {#if avatar}
            <img src={avatar} class="object-cover" />
          {:else}
            <Identicon {nickname} />
          {/if}
        </div>

        <div
          class="group-hover:absolute bg-black flex items-center justify-center left-0 right-0 top-0 bottom-0 m-1 rounded-lg"
        >
          <RotateCcw />
        </div>
      </div>
    </div>

    {#if !avatarOnly}
      <div class="text-xl grow mr-3">
        {nickname}
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
