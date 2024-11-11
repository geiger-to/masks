<script>
  import Pincode from "svelte-pincode/unstyled/Pincode.svelte";
  import PincodeInput from "svelte-pincode/unstyled/PincodeInput.svelte";

  export let auth;
  export let code;
  export let value;
  export let complete;
  export let length = 7;
  export let type;
  export let disabled;

  let pinClasses = [
    "no-inc py-3 grow w-[100%] input input-bordered px-1.5 md:px-3 text-center join-item",
  ];

  $: if (code) {
    code = code.map((v) => v.toUpperCase()).slice(0, 7);
  }

  $: classes = [
    ...pinClasses,
    auth?.warnings?.includes(`invalid-code:${value}`) ? "animate-denied" : "",
  ];
</script>

<Pincode
  {type}
  bind:code
  bind:value
  bind:complete
  class="flex items-center join mb-1.5"
  {disabled}
>
  {#each { length } as _, i}
    <PincodeInput placeholder="•" class={classes.join(" ")} />
  {/each}
</Pincode>
