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
          emails {
            nodes {
              address
              group
              createdAt
              verifiedAt
              actor {
                id
                name
                identifier
              }
            }
          }
        }
      `,
      requestPolicy: "network-only",
    })
  );

  let emails = $state([]);
  let subscribe = () => {
    query.subscribe((r) => {
      emails = r?.data?.emails?.nodes || [];
    });
  };

  subscribe();
</script>

{#each emails as email}
  <div class={"mb-1.5 bg-base-100 rounded-lg p-3 py-1.5"}>
    <div class="flex items-center gap-3 text-sm w-full">
      <a
        href={`mailto:${email.address}`}
        class="text-sm font-bold
        hover:underline focus:underline
        ">{email.address}</a
      >

      <a
        href={`/manage/actor/${email.actor.id}`}
        class="whitespace-nowrap
        hover:underline focus:underline
        opacity-75">{email.actor.name || email.actor.identifier}</a
      >

      <div class="grow"></div>

      <span class="whitespace-nowrap text-xs opacity-75"
        ><Time relative timestamp={email.createdAt} ago="old" /></span
      >
    </div>
  </div>
{/each}
