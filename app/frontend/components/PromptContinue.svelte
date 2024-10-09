<script>
  import _ from "lodash-es";

  export let loading;
  export let disabled;
  export let label = "continue";
  export let approve;
</script>

<button
  class={`btn btn-lg btn-primary ${$$props.class} w-[130px] text-center`}
  disabled={loading || disabled}
  {..._.omit($$props, ["disabled", "class"])}
>
  {#if loading}
    <span class="loading loading-spinner loading-md mx-auto"></span>
  {:else}
    {label}
  {/if}
</button>
