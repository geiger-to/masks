<script>
  import {
    Client,
    setContextClient,
    cacheExchange,
    fetchExchange,
  } from "@urql/svelte";
  import ErrorSection from "./ErrorSection.svelte";
  import AuthorizeSection from "./AuthorizeSection.svelte";
  import ManageSection from "./ManageSection.svelte";
  import { setContext } from "svelte";

  let csrf = document.querySelector('meta[name="csrf-token"]').content;

  function fetchOptions(csrf, options) {
    const update = { ...options };

    update.headers = {
      ...update.headers,
      "X-CSRF-Token": csrf,
    };

    return update;
  }

  let sections = {
    Error: ErrorSection,
    Authorize: AuthorizeSection,
    Manage: ManageSection,
  };

  export let section;

  const graphql = new Client({
    url: `/graphql${window.location.search}`,
    exchanges: [cacheExchange, fetchExchange],
    fetchOptions: () => {
      return {
        headers: { "X-CSRF-Token": csrf },
      };
    },
  });

  setContext("page", {
    csrf,
    section,
    graphql,
    fetch: (url, options) => {
      return fetch(url, fetchOptions(csrf, options));
    },
  });

  setContextClient(graphql);
</script>

<svelte:component this={sections[section]} {...$$props} />
