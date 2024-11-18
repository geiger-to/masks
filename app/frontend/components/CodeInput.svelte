<script>
  import { run } from "svelte/legacy";

  import Pincode from "svelte-pincode/unstyled/Pincode.svelte";
  import PincodeInput from "svelte-pincode/unstyled/PincodeInput.svelte";

  /**
   * @typedef {Object} Props
   * @property {any} auth
   * @property {any} onComplete
   * @property {number} [length]
   * @property {any} type
   * @property {any} disabled
   * @property {any} code
   * @property {any} value
   * @property {any} complete
   * @property {any} cls
   */

  /** @type {Props} */
  let {
    auth,
    onComplete,
    length = 7,
    type,
    disabled,
    code = $bindable(),
    value = $bindable(),
    complete = $bindable(),
    class: cls,
  } = $props();

  let lastValue;

  let pinClasses = [
    "no-inc py-3 grow w-[100%] input input-bordered px-1.5 md:px-3 text-center join-item font-bold",
  ];

  run(() => {
    if (code) {
      code = code.map((v) => v.toUpperCase()).slice(0, 7);
    }
  });

  let classes = $derived([
    ...pinClasses,
    auth?.warnings?.includes(`invalid-code:${value}`) ? "animate-denied" : "",
  ]);

  let handleComplete = (e) => {
    if (!onComplete) {
      return;
    }

    if (e.detail.value != lastValue) {
      onComplete(e);
      lastValue = e.detail.value;
    }
  };
</script>

<Pincode
  {type}
  bind:code
  bind:value
  bind:complete
  class="flex items-center join"
  {disabled}
  on:complete={handleComplete}
>
  {#each { length } as _, i}
    <PincodeInput
      placeholder={type == "numeric" ? "#" : "_"}
      class={[...classes, cls].join(" ")}
    />
  {/each}
</Pincode>
