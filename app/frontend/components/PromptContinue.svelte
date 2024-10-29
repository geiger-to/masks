<script>
  import _ from "lodash-es";

  export let event = null;
  export let loading;
  export let disabled;
  export let label = "continue";
  export let approve;
  export let denied = false;
  export let auth;
</script>

<button
  type="submit"
  class={`btn btn-lg min-w-[130px] ${$$props.class} text-center ${denied ? "animate-denied" : ""}`}
  disabled={loading || disabled}
  data-event={event}
  {..._.omit($$props, ["disabled", "class", "type", "loading"])}
>
  {#if loading}
    <span class="loading loading-spinner loading-md mx-auto"></span>
  {:else}
    <slot>
      {label}
    </slot>
  {/if}
</button>
