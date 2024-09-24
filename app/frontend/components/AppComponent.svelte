<script>
  import { Client, setContextClient, cacheExchange, fetchExchange } from '@urql/svelte';
  import ErrorSection from "./ErrorSection.svelte";
  import AuthorizeSection from "./AuthorizeSection.svelte";

  let csrf = document.querySelector('meta[name="csrf-token"]').content
  let sections = {
    'Error': ErrorSection,
    'Authorize': AuthorizeSection
  }

  export let section;

  const client = new Client({
    url: '/graphql',
    exchanges: [cacheExchange, fetchExchange],
    fetchOptions: () => {
      return {
        headers: { 'X-CSRF-Token': csrf }
      }
    }
  });

  setContextClient(client);
</script>

<svelte:component this={sections[section]} {...$$props} />
