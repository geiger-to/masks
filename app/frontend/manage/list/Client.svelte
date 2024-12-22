<script>
  import Time from "@/components/Time.svelte";
  import EditableImage from "@/components/EditableImage.svelte";
  import QuerySearch from "@/components/QuerySearch.svelte";
  import PaginateSearch from "@/components/PaginateSearch.svelte";
  import { queryStore, gql, getContextClient } from "@urql/svelte";

  let { timestamps = true, ...props } = $props();
  let variables = $state({});
  let loading = $state(true);
  let query = $derived(
    queryStore({
      client: getContextClient(),
      pause: props.clients,
      query: gql`
        query ($name: String, $actor: String, $device: String) {
          clients(name: $name, actor: $actor, device: $device) {
            nodes {
              id
              name
              logo
              createdAt
            }
          }
        }
      `,
      variables,
      requestPolicy: "network-only",
    })
  );

  let clients = $state([]);
  let subscribe = (qs) => {
    variables = qs;

    query.subscribe((r) => {
      clients = r?.data?.clients?.nodes || [];
      loading = !r?.data;
    });
  };
</script>

{#if !props.clients}
  <PaginateSearch
    label="Clients"
    class="mb-3"
    onchange={console.log}
    count={clients?.length}
    {loading}
  />

  <QuerySearch
    url="/manage/clients"
    keys={["name", "actor", "device"]}
    class="mb-3"
    onquery={subscribe}
    empty={clients?.length == 0}
    {loading}
  />
{/if}

{#each clients as client}
  <a href={`/manage/client/${client.id}`} class="mb-1.5">
    <div class="bg-base-100 rounded-lg p-1.5 text-base-content">
      <div class="flex items-center gap-2">
        <EditableImage
          disabled
          params={{ client_id: client.id }}
          src={client.logo}
          class="w-8 h-8"
        />

        <div class="grow">
          <div class="font-bold text-xs">
            {client.name}
          </div>
          <div class="font-mono text-xs flex items-center gap-1.5">
            <span class="opacity-75">id</span>
            {client.id}
          </div>
        </div>

        {#if timestamps}
          <div class="text-xs font-normal opacity-75 truncate pr-1.5">
            <Time relative timestamp={client.createdAt} ago="old" />
          </div>
        {/if}
      </div>
    </div>
  </a>
{/each}
