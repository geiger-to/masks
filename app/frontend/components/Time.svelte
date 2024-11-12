<script>
  import { DateTime } from "luxon";
  import { onMount, onDestroy } from "svelte";

  export let timestamp;
  export let style = "narrow";

  let time;
  let intervalId;
  let interval;

  function updateTime(ts) {
    time = DateTime.fromISO(ts).toRelative({ style, base: DateTime.now() });
    time = time
      .replace(/ago$/, $$props.ago || "ago")
      .replace(/^in/, $$props.in || "in");

    interval = time?.includes("sec") ? 1000 : 60 * 1000;
  }

  onMount(() => {
    updateTime(timestamp);

    intervalId = setInterval(() => {
      updateTime(timestamp);
    }, interval);
  });

  onDestroy(() => {
    clearInterval(intervalId);
  });

  $: updateTime(timestamp);
</script>

<span>{time}</span>
