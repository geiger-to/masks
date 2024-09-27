<script>
  import AddClientComponent from "./AddClientComponent.svelte";
  import AddActorComponent from "./AddActorComponent.svelte";
  import ClientCard from "./ClientCard.svelte";
  import ActorCard from "./ActorCard.svelte";
  import Identicon from "./Identicon.svelte";
  import { onMount } from "svelte";
  import { queryStore, gql, getContextClient } from "@urql/svelte";
  import Time from "svelte-time";
  import { UserPlus, X, Plus, Search } from "lucide-svelte";
  import _ from "lodash-es";

  export let nickname;

  let isAdding;
  let input;
  let query;
  let loading;

  $: query = queryStore({
    client: getContextClient(),
    query: gql`
      query ($input: String!) {
        search(query: $input) {
          actors {
            nickname
            password
            scopes
            lastLoginAt
            createdAt
            updatedAt
            changedPasswordAt
            addedTotpSecretAt
            savedBackupCodesAt
          }
          clients {
            id
            name
            type
            secret
            redirectUris
            scopes
            consent
            createdAt
            updatedAt
          }
        }
      }
    `,
    variables: { input: input || "" },
    requestPolicy: "network-only",
    pause: true,
  });

  const search = (value) => {
    input = value;
    isAdding = false;
  };

  const adding = (name) => {
    return () => {
      isAdding = name;
    };
  };

  let client = getContextClient();

  let autocomplete = (q) => {
    if (q) {
      loading = true;

      doQuery();
    }
  };

  let doQuery = _.debounce((arg) => {
    if (!input) {
      return;
    }

    query.resume();

    loading = false;
  }, 300);

  $: autocomplete(input);
</script>

<div class="">
  <div class="navbar bg-base-200 mb-6 my-0 min-h-0">
    <div class="navbar-start">
      <div class="text-lg font-bold ml-6 text-primary">masks</div>
    </div>

    <div class="navbar-end pr-6">
      <a
        href="#"
        on:click|preventDefault|stopPropagation={() => search(`@${nickname}`)}
      >
        <div class="avatar placeholder">
          <div
            class="dark:bg-black bg-white text-neutral-content rounded-lg w-8 p-0.5"
          >
            <Identicon {nickname} />
          </div>
        </div>
      </a>
    </div>
  </div>

  <div class="px-6">
    {#if isAdding == "actor"}
      <AddActorComponent cancel={adding(null)} {search} />
    {:else if isAdding == "client"}
      <AddClientComponent cancel={adding(null)} {search} />
    {:else}
      <div class="flex items-center join">
        <label
          class="input input-bordered flex items-center gap-3 grow
          join-item"
        >
          {#if loading}
            <span class="loading loading-spinner"></span>
          {:else}
            <Search />
          {/if}

          <input
            type="text"
            class="grow"
            placeholder="search for actors, clients, devices, and more..."
            bind:value={input}
          />
        </label>

        <div class={isAdding ? "" : `dropdown dropdown-hover dropdown-end`}>
          <div tabindex="0" role="button" class={`btn btn-success join-item`}>
            <Plus />
          </div>

          <ul
            tabindex="0"
            class="dropdown-content menu bg-white dark:bg-black
          rounded-box z-[1] p-2 shadow-lg [&>li]:my-1.5"
          >
            <li>
              <button
                on:click={adding("actor")}
                class="btn text-lg whitespace-nowrap">new actor</button
              >
            </li>
            <li>
              <button
                on:click={adding("client")}
                class="btn text-lg whitespace-nowrap">new client</button
              >
            </li>
          </ul>
        </div>
      </div>
      {#if !input}
        <div class="rounded-lg border-dashed border-2 border-base-300 p-6 mt-3">
          <ul class="opacity-75 gap-3 flex flex-col">
            <li class="flex items-center">
              <span class="grow font-mono">...</span> find a client by its id
            </li>
            <li class="flex items-center">
              <span class="grow font-mono">@...</span> find an actor by nickname
            </li>
            <li class="flex items-center">
              <span class="grow font-mono">@example.com...</span> find an actor by
              email domain
            </li>
            <li class="flex items-center">
              <span class="grow font-mono">email@example.com...</span> find an actor
              by email
            </li>
          </ul>
        </div>
      {:else if $query?.data?.search?.actors?.length}
        {#each $query.data.search.actors as actor}
          <ActorCard {actor} editing={$query.data.search.actors.length == 1} />
        {/each}
      {:else if $query?.data?.search?.clients?.length}
        {#each $query.data.search.clients as client}
          <ClientCard
            {client}
            editing={$query.data.search.clients.length == 1}
          />
        {/each}
      {/if}
    {/if}
  </div>
</div>
