<script>
  export let value;

  let dropdown;
  let setValue = (v, cb) => {
    value = v;

    if (dropdown) {
      dropdown.open = false;
    }

    if (cb) {
      cb(v);
    }
  };
</script>

<details class={`dropdown ${$$props.class}`} bind:this={dropdown}>
  <slot name="summary" {value} />
  <div
    class="dropdown-content dark:bg-black bg-neutral p-1.5 px-3 rounded-lg shadow-xl mt-1.5 z-20"
  >
    <slot name="dropdown" {value} {setValue} />
  </div>
</details>
