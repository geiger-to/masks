<script>
  import Pincode from "svelte-pincode/unstyled/Pincode.svelte";
  import PincodeInput from "svelte-pincode/unstyled/PincodeInput.svelte";

  export let auth;
  export let code;
  export let value;
  export let complete;

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
  bind:code
  bind:value
  bind:complete
  class="flex items-center join mb-1.5 rounded-t-none"
>
  <PincodeInput placeholder="•" class={classes.join(" ")} />
  <PincodeInput placeholder="•" class={classes.join(" ")} />
  <PincodeInput placeholder="•" class={classes.join(" ")} />
  <PincodeInput placeholder="•" class={classes.join(" ")} />
  <PincodeInput placeholder="•" class={classes.join(" ")} />
  <PincodeInput placeholder="•" class={classes.join(" ")} />
  <PincodeInput placeholder="•" class={classes.join(" ")} />
</Pincode>
