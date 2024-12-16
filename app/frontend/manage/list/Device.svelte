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
              deviceName
              deviceType
              osName
              ipAddress
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

  let icon = {
    desktop: Computer,
    smartphone: Smartphone,
    "feature phone": Smartphone,
    tablet: Tablet,
    phablet: Tablet,
    "portable media player": Tablet,
    console: Gamepad,
    tv: Tv,
    "smart display": Tv2,
    "car browser": Car,
    camera: Camera,
    "smart speaker": Bluetooth,
    wearable: Bluetooth,
    peripheral: Bluetooth,
  };
</script>

{#each devices as device}
  {@const Icon = icon[device.deviceType] || HelpCircle}

  <div class={"mb-1.5 bg-base-100 rounded-lg p-3 py-1.5"}>
    <div class="flex items-center gap-3 text-sm w-full">
      <div class="px-1.5">
        <Icon size="14" />
      </div>

      <span class="whitespace-nowrap font-bold" alt={device.userAgent}
        >{device.name} on {device.osName}</span
      >
      <span class="text-xs font-mono grow">{device.ipAddress}</span>

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
