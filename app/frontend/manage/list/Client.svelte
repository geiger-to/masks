<script>
  import Time from "@/components/Time.svelte";
  import EditableImage from "@/components/EditableImage.svelte";
  import { queryStore, gql, getContextClient } from "@urql/svelte";

  let props = $props();
  let query = $derived(
    queryStore({
      client: getContextClient(),
      query: gql`
        query {
          clients {
            nodes {
              id
              name
              logo
              createdAt
            }
          }
        }
      `,
      requestPolicy: "network-only",
    })
  );

  let clients = $state([]);
  let subscribe = () => {
    query.subscribe((r) => {
      clients = r?.data?.clients?.nodes || [];
    });
  };

  subscribe();
</script>

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

        <div class="text-xs font-normal opacity-75 truncate pr-1.5">
          <Time relative timestamp={client.createdAt} ago="old" />
        </div>
      </div>
    </div>
  </a>
{/each}
