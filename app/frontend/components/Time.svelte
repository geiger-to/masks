<script>
  import { DateTime } from "luxon";
  import { onMount, onDestroy } from "svelte";

  export let timestamp;
  export let interval = 60000;
  export let style = "narrow";

  let time;

  function updateTime(ts) {
    time = DateTime.fromISO(ts).toRelative({ style, base: DateTime.now() });
    time = time
      .replace(/ago$/, $$props.ago || "ago")
      .replace(/^in/, $$props.in || "in");
  }

  let intervalId;

  onMount(() => {
    updateTime(timestamp);

    intervalId = setInterval(() => {
      updateTime(timestamp);
    }, 15000);
  });

  onDestroy(() => {
    clearInterval(intervalId);
  });

  $: updateTime(timestamp);
</script>

<span>{time}</span>
