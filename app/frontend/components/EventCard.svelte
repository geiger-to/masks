<script>
  import { Save, ChevronDown, X } from "lucide-svelte";
  import Time from "svelte-time";

  export let event;
  export let search;

  let form = { ...event };
</script>

<div class="my-1.5 bg-base-200 rounded-lg p-3 px-3">
  <div class="flex items-center pl-1.5 gap-3">
    <h2 class="font-bold font-mono">{event.name}</h2>
    <a
      href="#"
      on:click|preventDefault|stopPropagation={search(event.clientId)}
      class="underline">{event.clientId}</a
    >
    <span class="text-sm" alt={event.device.userAgent}
      >{event.device.name} on {event.device.osName}</span
    >
    <span class="text-sm font-mono">{event.device.ipAddress}</span>
    <span class="italic"><Time relative timestamp={event.createdAt} /></span>
  </div>
</div>
