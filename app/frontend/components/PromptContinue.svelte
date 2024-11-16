<script>
  import _ from "lodash-es";

  export let event = null;
  export let loading;
  export let disabled;
  export let label = "continue";
  export let denied = false;
  export let deniedLabel = "try again";
  export let onClick;
  export let type;

  let handleClick = (e) => {
    if (onClick) {
      e.preventDefault();
      e.stopPropagation();

      return onClick(e);
    }
  };

  let defaultType;

  $: defaultType = onClick ? "button" : "submit";
</script>

<button
  type={type || defaultType}
  class={`btn btn-lg min-w-[130px] ${$$props.class} text-center ${denied ? "animate-denied" : ""}`}
  disabled={loading || disabled}
  data-event={event}
  on:click={handleClick}
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
