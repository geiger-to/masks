<script>
  import { Eye, EyeOff } from "lucide-svelte";

  let visible = false;
  let toggle = () => {
    visible = !visible;
  };

  export let value;
  export let label = null;
  export let disabled;
  export let auth;
  export let placeholder;
  export let valid;
  export let onChange;

  let min;
  let max;
  let info;

  $: min = auth?.settings?.passwords?.min;
  $: max = auth?.settings?.passwords?.max;

  $: if (!disabled && min && max) {
    valid = value && value.length >= min && value.length <= max;
    info = `(${min} to ${max} characters)`;
  } else {
    valid = true;
  }
</script>

<label class={`input input-bordered flex items-center gap-3 ${$$props.class}`}>
  <slot name="before" />

  {#if label}
    <span class="label-text opacity-70 w-[70px]">{label}</span>
  {/if}

  {#if visible}
    <input
      minlength={min}
      maxlength={max}
      {...$$props}
      type="text"
      placeholder={`${[placeholder, info].filter(Boolean).join(" ")}`}
      class={`placeholder:text-sm md:placeholder:text-base min-w-0 grow ${$$props.inputClass}`}
      bind:value
      on:input={onChange}
    />
  {:else}
    <input
      minlength={min}
      maxlength={max}
      {...$$props}
      type="password"
      placeholder={`${[placeholder, info].filter(Boolean).join(" ")}`}
      class={`placeholder:text-sm md:placeholder:text-base min-w-0 grow ${$$props.inputClass}`}
      bind:value
      on:input={onChange}
    />
  {/if}

  <slot name="right" />

  <button on:click|preventDefault|stopPropagation={toggle} type="button">
    <svelte:component this={visible ? EyeOff : Eye} />
  </button>
</label>
