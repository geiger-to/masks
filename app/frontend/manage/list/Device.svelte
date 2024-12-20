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
  import { route } from "@mateothegreat/svelte5-router";
  import Time from "@/components/Time.svelte";
  import EditableImage from "@/components/EditableImage.svelte";
  import DeviceIcon from "@/components/DeviceIcon.svelte";
  import QuerySearch from "@/components/QuerySearch.svelte";
  import PaginateSearch from "@/components/PaginateSearch.svelte";
  import { queryStore, gql, getContextClient } from "@urql/svelte";

  let props = $props();
  let variables = $state(null);
  let loading = $state(true);
  let query = $derived(
    queryStore({
      client: getContextClient(),
      pause: props.devices,
      query: gql`
        query ($id: String, $actor: String) {
          devices(id: $id, actor: $actor) {
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
      variables,
      requestPolicy: "network-only",
    })
  );

  let devices = $state([]);
  let subscribe = (qs) => {
    variables = qs;

    query.subscribe((r) => {
      devices = r?.data?.devices?.nodes || [];
      loading = !r?.data;
    });
  };
</script>

{#if !props.devices}
  <PaginateSearch
    label="Devices"
    class="mb-3"
    onchange={console.log}
    count={devices?.length}
    {loading}
  />

  <QuerySearch
    url="/manage/devices"
    keys={["id", "actor"]}
    class="mb-3"
    onquery={subscribe}
    empty={devices?.length == 0}
    {loading}
  />
{/if}

{#each devices as device}
  <a use:route href={`/manage/device/${device.id}`}>
    <span class={"block mb-1.5 bg-base-100 rounded-lg p-3 py-1.5"}>
      <span class="flex items-center gap-3 text-sm w-full">
        <span class="px-1.5">
          <DeviceIcon {device} size="14" />
        </span>

        <span class="whitespace-nowrap font-bold" alt={device.userAgent}
          >{device.name} on {device.os}</span
        >
        <span class="text-xs font-mono grow">{device.ip}</span>

        <span
          class="text-[10px] font-mono opacity-75
          truncate"
        >
          {device.id}
        </span>

        <span class="whitespace-nowrap text-xs opacity-75"
          ><Time relative timestamp={device.createdAt} ago="old" /></span
        >
      </span>
    </span>
  </a>
{/each}
