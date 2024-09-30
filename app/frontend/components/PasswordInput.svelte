<script>
  import { Eye, EyeOff } from "lucide-svelte";

  let visible = false;
  let toggle = () => {
    visible = !visible;
  };

  export let value;
  export let label = null;
</script>

<label class={`input input-bordered flex items-center gap-3 ${$$props.class}`}>
  {#if label}
    <span class="label-text opacity-70 w-[70px]">{label}</span>
  {/if}

  {#if visible}
    <input type="text" {...$$props} class="grow" bind:value />
  {:else}
    <input type="password" {...$$props} class="grow" bind:value />
  {/if}
  <slot name="right" />
  <button on:click|preventDefault|stopPropagation={toggle} type="button">
    <svelte:component this={visible ? EyeOff : Eye} />
  </button>
</label>
