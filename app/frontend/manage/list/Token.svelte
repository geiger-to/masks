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
  import QuerySearch from "@/components/QuerySearch.svelte";
  import PaginateSearch from "@/components/PaginateSearch.svelte";
  import { queryStore, gql, getContextClient } from "@urql/svelte";

  let props = $props();
  let variables = $state(null);
  let loading = $state(true);
  let query = $derived(
    queryStore({
      client: getContextClient(),
      pause: props.tokens,
      query: gql`
        query ($actor: String) {
          tokens(actor: $actor) {
            nodes {
              id
              token
              scopes
              createdAt
              expiresAt
              refreshedAt
            }
          }
        }
      `,
      variables,
      requestPolicy: "network-only",
    })
  );

  let tokens = $state([]);
  let subscribe = (qs) => {
    variables = qs;

    query.subscribe((r) => {
      tokens = r?.data?.tokens?.nodes || [];
      loading = !r?.data;
    });
  };
</script>

{#if !props.tokens}
  <PaginateSearch
    label="Tokens"
    class="mb-3"
    onchange={console.log}
    count={tokens?.length}
    {loading}
  />

  <QuerySearch
    url="/manage/tokens"
    keys={["actor", "device", "client"]}
    class="mb-3"
    onquery={subscribe}
    empty={tokens?.length == 0}
    {loading}
  />
{/if}

{#each tokens as token}
  <div class={"block mb-1.5 bg-base-100 rounded-lg p-3 py-1.5"}>
    <div class="flex items-center gap-3 text-sm w-full">
      <div class="whitespace-nowrap font-bold" alt={token.userAgent}>
        {token.name} on {token.os}
      </div>
      <div class="text-xs font-mono grow">{token.ip}</div>

      <div
        class="text-[10px] font-mono opacity-75
        truncate"
      >
        {token.id}
      </div>

      <div class="whitespace-nowrap text-xs opacity-75">
        <Time relative timestamp={token.createdAt} ago="old" />
      </div>
    </div>
  </div>
{/each}
