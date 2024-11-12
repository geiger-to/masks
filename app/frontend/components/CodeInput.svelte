<script>
  import Pincode from "svelte-pincode/unstyled/Pincode.svelte";
  import PincodeInput from "svelte-pincode/unstyled/PincodeInput.svelte";

  export let auth;
  export let onComplete;
  export let length = 7;
  export let type;
  export let disabled;
  export let code;
  export let value;
  export let complete;

  let lastValue;

  let pinClasses = [
    "no-inc py-3 grow w-[100%] input input-bordered px-1.5 md:px-3 text-center join-item font-bold",
  ];

  $: if (code) {
    code = code.map((v) => v.toUpperCase()).slice(0, 7);
  }

  $: classes = [
    ...pinClasses,
    auth?.warnings?.includes(`invalid-code:${value}`) ? "animate-denied" : "",
  ];

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
      class={[...classes, $$props.class].join(" ")}
    />
  {/each}
</Pincode>
