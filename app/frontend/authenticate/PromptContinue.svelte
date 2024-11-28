<script>
  import _ from "lodash-es";

  let {
    children,
    loading,
    disabled,
    event = null,
    label = "continue",
    denied = false,
    deniedLabel = "try again",
    updates = {},
    authorize,
    type = "button",
    class: cls,
    ...extraProps
  } = $props();

  let onclick = (e) => {
    if (extraProps.onclick) {
      return extraProps.onclick(e);
    } else if (authorize) {
      e.preventDefault();
      e.stopPropagation();

      authorize({ event, updates });
    }
  };
</script>

<button
  {...extraProps}
  {type}
  class={`btn btn-lg min-w-[130px] ${cls} text-center ${denied ? "animate-denied" : ""}`}
  disabled={loading || disabled}
  {onclick}
>
  {#if loading}
    <span class="loading loading-spinner loading-md mx-auto"></span>
  {:else if children}{@render children()}{:else}
    {denied ? deniedLabel : label}
  {/if}
</button>
