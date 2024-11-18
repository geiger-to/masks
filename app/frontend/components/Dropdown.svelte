<script>
  let { value, class: cls, summary, dropdown } = $props();

  let element;
  let setValue = (v, cb) => {
    value = v;

    if (element) {
      element.open = false;
    }

    if (cb) {
      cb(v);
    }
  };
</script>

<details class={`dropdown ${cls}`} bind:this={element}>
  {@render summary?.({value})}
  <div
    class="dropdown-content dark:bg-black bg-neutral p-1.5 px-3 rounded-lg shadow-xl mt-1.5 z-20"
  >
    {@render dropdown?.({value, setValue})}
  </div>
</details>
