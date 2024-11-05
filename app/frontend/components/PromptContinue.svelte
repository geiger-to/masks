<script>
  import _ from "lodash-es";

  export let element;
  export let event = null;
  export let loading;
  export let disabled;
  export let label = "continue";
  export let approve;
  export let denied = false;
  export let deniedLabel = "try again";
  export let auth;
  export let type = "submit";
</script>

<button
  bind:this={element}
  {type}
  class={`btn btn-lg min-w-[130px] ${$$props.class} text-center ${denied ? "animate-denied" : ""}`}
  disabled={loading || disabled}
  data-event={event}
  {..._.omit($$props, ["disabled", "class", "type", "loading"])}
>
  {#if loading}
    <span class="loading loading-spinner loading-md mx-auto"></span>
  {:else}
    <slot>
      {denied ? deniedLabel : label}
    </slot>
  {/if}
</button>
