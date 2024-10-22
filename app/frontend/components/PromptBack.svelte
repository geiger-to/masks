<script>
  import _ from "lodash-es";

  export let loading;
  export let disabled;
  export let label = "go back";
</script>

<a
  class="btn btn-lg btn-error w-[130px] text-center"
  disabled={loading || disabled}
  on:click|preventDefault|stopPropagation={() => history.back()}
  {..._.omit($$props, ["label", "loading", "disabled", "class"])}
>
  {#if loading}
    <span class="loading loading-spinner loading-md mx-auto"></span>
  {:else}
    {label}
  {/if}
</a>
