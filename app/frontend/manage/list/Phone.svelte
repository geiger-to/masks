<script>
  import Time from "@/components/Time.svelte";
  import PhoneInput from "@/components/PhoneInput.svelte";
  import { queryStore, gql, getContextClient } from "@urql/svelte";

  let props = $props();
  let query = $derived(
    queryStore({
      client: getContextClient(),
      query: gql`
        query {
          phones {
            nodes {
              number
              createdAt
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

  let phones = $state([]);
  let subscribe = () => {
    query.subscribe((r) => {
      phones = r?.data?.phones?.nodes || [];
    });
  };

  subscribe();
</script>

{#each phones as phone}
  <div class={"mb-1.5 bg-base-100 rounded-lg pr-3"}>
    <div class="flex items-center gap-3 text-sm w-full">
      <PhoneInput value={phone.number} disabled />

      <div class="grow"></div>

      <span class="whitespace-nowrap text-xs opacity-75 pr-1.5"
        ><Time relative timestamp={phone.createdAt} ago="old" /></span
      >
    </div>
  </div>
{:else}
  <div
    class="border-2 border-dashed p-10 rounded-lg border-gray-400 dark:border-neutral text-center opacity-50"
  >
    nothing found...
  </div>
{/each}
