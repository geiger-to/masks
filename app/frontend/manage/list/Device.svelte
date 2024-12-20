<script>
  import {
    Save,
    ChevronDown,
    X,
    Computer,
    Smartphone,
    Tablet,
    Gamepad,
    Tv,
    Tv2,
    HelpCircle,
    Car,
    Camera,
    Bluetooth,
  } from "lucide-svelte";
  import Time from "@/components/Time.svelte";
  import EditableImage from "@/components/EditableImage.svelte";
  import DeviceIcon from "@/components/DeviceIcon.svelte";
  import { queryStore, gql, getContextClient } from "@urql/svelte";

  let props = $props();
  let query = $derived(
    queryStore({
      client: getContextClient(),
      query: gql`
        query {
          devices {
            nodes {
              id
              name
              type
              ip
              os
              userAgent
              createdAt
            }
          }
        }
      `,
      requestPolicy: "network-only",
    })
  );

  let devices = $state([]);
  let subscribe = () => {
    query.subscribe((r) => {
      devices = r?.data?.devices?.nodes || [];
    });
  };

  subscribe();
</script>

{#each devices as device}
  <div class={"mb-1.5 bg-base-100 rounded-lg p-3 py-1.5"}>
    <div class="flex items-center gap-3 text-sm w-full">
      <div class="px-1.5">
        <DeviceIcon {device} size="14" />
      </div>

      <span class="whitespace-nowrap font-bold" alt={device.userAgent}
        >{device.name} on {device.os}</span
      >
      <span class="text-xs font-mono grow">{device.ip}</span>

      <div
        class="text-[10px] font-mono opacity-75
        truncate"
      >
        {device.id}
      </div>

      <span class="whitespace-nowrap text-xs opacity-75"
        ><Time relative timestamp={device.createdAt} ago="old" /></span
      >
    </div>
  </div>
{/each}
