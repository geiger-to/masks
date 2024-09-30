<script>
  import { Save, ChevronDown, X } from "lucide-svelte";
  import Time from "svelte-time";
  import DeviceCard from "./DeviceCard.svelte";

  export let event;
  export let search;

  let form = { ...event };
</script>

<div class="my-1.5 bg-base-200 rounded-lg p-3 px-3">
  <div class="flex items-center pl-1.5 gap-3">
    <h2 class="font-bold font-mono">{event.name}</h2>
    <span class="opacity-70">via</span>
    <div class="grow">
      <a
        href="#"
        on:click|preventDefault|stopPropagation={search(event.clientId)}
        class="underline">{event.clientId}</a
      >
    </div>

    <DeviceCard inline device={event.device} />
  </div>
</div>
