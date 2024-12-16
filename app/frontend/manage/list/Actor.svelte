<script>
  import { route } from "@mateothegreat/svelte5-router";
  import Time from "@/components/Time.svelte";
  import Avatar from "@/components/Avatar.svelte";
  import { queryStore, gql, getContextClient } from "@urql/svelte";
  import ActorResult from "../ActorResult.svelte";

  let props = $props();
  let query = $derived(
    queryStore({
      client: getContextClient(),
      query: gql`
        query {
          actors {
            nodes {
              id
              name
              identifier
              identiconId
              lastLoginAt
              createdAt
            }
          }
        }
      `,
      requestPolicy: "network-only",
    })
  );

  let actors = $state([]);
  let subscribe = () => {
    query.subscribe((r) => {
      actors = r?.data?.actors?.nodes || [];
    });
  };

  subscribe();
</script>

{#each actors as actor}
  <a
    use:route
    href={`/manage/actor/${actor.id}`}
    class="bg-base-100 rounded-lg p-1.5 block mb-1.5"
  >
    <div class="grow flex items-center gap-3">
      <div class="w-6 h-6">
        <Avatar {actor} />
      </div>
      <div class="flex items-center gap-1.5 grow pr-1.5 w-full overflow-hidden">
        <b class="">
          {actor.identifier}
        </b>

        <div
          class="grow text-xs font-normal opacity-75 hidden md:block truncate"
        >
          <Time relative timestamp={actor.createdAt} ago="old" />
        </div>

        <div class="text-xs font-normal opacity-75 truncate">
          last login

          <span class="italic">
            {#if actor.lastLoginAt}
              <Time relative timestamp={actor.lastLoginAt} />
            {:else}
              never
            {/if}
          </span>
        </div>
      </div>
    </div>
  </a>
{/each}
