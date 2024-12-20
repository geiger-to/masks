<script>
  import { route } from "@mateothegreat/svelte5-router";
  import { Search, ChevronRight } from "lucide-svelte";
  import Time from "@/components/Time.svelte";
  import Identicon from "@/components/Identicon.svelte";
  import EditableImage from "@/components/EditableImage.svelte";
  import DeviceIcon from "@/components/DeviceIcon.svelte";
  import { queryStore, gql, getContextClient } from "@urql/svelte";
  import QuerySearch from "@/components/QuerySearch.svelte";
  import PaginateSearch from "@/components/PaginateSearch.svelte";

  let props = $props();
  let variables = $state(null);
  let loading = $state(true);
  let query = $derived(
    queryStore({
      client: getContextClient(),
      pause: !variables,
      query: gql`
        query ($actor: String, $client: String, $device: String) {
          entries(actor: $actor, client: $client, device: $device) {
            nodes {
              actor {
                id
                name
                identifier
                identiconId
              }
              device {
                id
                name
                type
                userAgent
                os
              }
              client {
                id
                name
              }
              createdAt
            }
          }
        }
      `,
      variables,
      requestPolicy: "network-only",
    })
  );

  let entries = $state([]);
  let subscribe = (qs) => {
    variables = qs;

    query.subscribe((r) => {
      entries = r?.data?.entries?.nodes || [];
      loading = !r?.data;
    });

    query.resume();
  };
</script>

<PaginateSearch
  label="Entries"
  class="mb-3"
  placeholder="Filter entries..."
  onchange={console.log}
  count={entries?.length}
  {loading}
/>

<QuerySearch
  keys={["actor", "client", "device"]}
  class="mb-3"
  onquery={subscribe}
  empty={entries?.length == 0}
  {loading}
/>

{#each entries as entry}
  <div class={"bg-base-100 rounded-lg px-3 mb-1.5 overflow-hidden max-w-full"}>
    <div class="flex items-center gap-1.5 w-full">
      <a
        use:route
        href={`/manage/actor/${entry.actor.id}`}
        class="
        -ml-1
        truncate
        flex items-center gap-1.5
        hover:underline focus:underline"
      >
        <div class="min-w-6 w-6 h-6 bg-black rounded p-[1px] my-1.5">
          <Identicon id={entry.actor.identiconId} />
        </div>

        <span
          class="truncate
        font-bold text-sm">{entry.actor.name || entry.actor.identifier}</span
        >
      </a>

      <ChevronRight size="10" />

      <a
        use:route
        class="truncate text-sm hover:underline focus:underline"
        href={`/manage/client/${entry.client.id}`}
        >{entry.client.name || entry.client.key}</a
      >

      <div class="grow"></div>

      <div class="truncate text-xs opacity-75">
        <Time relative timestamp={entry.createdAt} />
      </div>

      <a
        use:route
        href={`/manage/device/${entry.device.id}`}
        class="flex items-center
 hover:underline focus:underline
          gap-1.5"
      >
        <DeviceIcon size="10" device={entry.device} />

        <span
          class="truncate text-xs hidden md:block"
          alt={entry.device.userAgent}
          >{entry.device.name} on {entry.device.os}</span
        >
      </a>
    </div>
  </div>
{/each}
