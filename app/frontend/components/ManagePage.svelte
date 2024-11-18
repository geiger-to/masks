<script>
  import { run, preventDefault, stopPropagation } from "svelte/legacy";

  import Avatar from "./Avatar.svelte";
  import PasswordInput from "./PasswordInput.svelte";
  import AddClientComponent from "./AddClientComponent.svelte";
  import AddActorComponent from "./AddActorComponent.svelte";
  import SettingsCard from "./SettingsCard.svelte";
  import EventCard from "./EventCard.svelte";
  import DeviceCard from "./DeviceCard.svelte";
  import TokenCard from "./TokenCard.svelte";
  import CodeCard from "./CodeCard.svelte";
  import JwtCard from "./JwtCard.svelte";
  import ClientCard from "./ClientCard.svelte";
  import ActorCard from "./ActorCard.svelte";
  import Identicon from "./Identicon.svelte";
  import { onMount } from "svelte";
  import { queryStore, gql, getContextClient } from "@urql/svelte";
  import Time from "svelte-time";
  import {
    PlusSquare,
    Cog,
    ListCheck,
    UserPlus,
    X,
    Plus,
    Search,
    ChevronLeft,
  } from "lucide-svelte";
  import _ from "lodash-es";

  let { actor } = $props();

  let { nickname } = actor;

  let isConfiguring = $state();
  let isAdding = $state();
  let isAddOpen = $state();
  let isEditing = $state();
  let input = $state();
  let query = $derived(
    queryStore({
      client: getContextClient(),
      query: gql`
        query ($input: String!) {
          search(query: $input) {
            actors {
              id
              nickname
              identiconId
              password
              scopes
              avatar
              lastLoginAt
              createdAt
              updatedAt
              passwordChangedAt
              addedTotpSecretAt
              savedBackupCodesAt
            }
            clients {
              id
              name
              type
              logo
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
      variables: {
        input: input || "",
      },
      requestPolicy: "network-only",
    })
  );
  let result = $state();
  let loading = $state();

  const search = (value) => {
    input = value;
    isAddOpen = false;
    isAdding = false;
    isConfiguring = false;
    isEditing = false;
  };

  const configuring = () => {
    isAddOpen = false;
    isAdding = false;
    isConfiguring = !isConfiguring;
  };

  const including = () => {
    isAddOpen = false;
    isAdding = false;
  };

  let editing = (object) => {
    isEditing = object;
  };

  let adding = (name) => {
    return () => {
      isAddOpen = false;
      isConfiguring = false;
      isAdding = name;
    };
  };

  let toggleMenu = () => {
    if (isAddOpen || isAdding) {
      isAddOpen = false;
      isAdding = null;
    } else {
      isAddOpen = true;
      isAdding = null;
    }
  };

  let client = getContextClient();

  let autocomplete = (i, query) => {
    if (i) {
      loading = true;

      if (query?.data?.search) {
        result = query?.data?.search;
      }

      doQuery(query);
    }
  };

  let doQuery = _.debounce((query) => {
    if (!input) {
      return;
    }

    loading = false;
  }, 300);

  let isOneOf = (search) => {
    return search?.actors?.length == 1 || search?.clients?.length == 1;
  };

  let isEmpty = (search) => {
    return search && !search.actors?.length && !search.clients?.length;
  };

  run(() => {
    autocomplete(input, $query);
  });
</script>

<div class="dark:bg-black bg-base-300 h-full">
  <div class="navbar bg-base-200 my-0 min-h-0">
    <div class="navbar-start">
      <div class="text-lg font-bold ml-4 text-black dark:text-white">masks</div>
    </div>

    <div class="navbar-end pr-3 flex items-center gap-1">
      <button
        class={`btn btn-sm px-0 w-8 ${isConfiguring ? "btn-neutral" : "btn-ghost"}`}
        type="button"
        onclick={stopPropagation(preventDefault(configuring))}
      >
        {#if isConfiguring}
          <X size="20" />
        {:else}
          <Cog size="20" />
        {/if}
      </button>

      <div class={`dropdown ${isAddOpen ? "dropdown-open" : ""} dropdown-end`}>
        <button
          tabindex="0"
          onclick={stopPropagation(preventDefault(toggleMenu))}
          class={`btn ${!isAdding && "focus:btn-success hover:btn-success"} btn-sm px-0 w-8 py-0`}
        >
          {#if isAddOpen || isAdding}
            <X size="20" />
          {:else}
            <PlusSquare size="20" />
          {/if}
        </button>

        {#if isAddOpen}
          <div
            class="dropdown-content bg-white dark:bg-black
        rounded-lg z-[1] p-2 py-1.5 shadow-lg [&>li]:my-1"
          >
            <ul class="menu gap-3">
              <li>
                <button
                  onclick={stopPropagation(preventDefault(adding("actor")))}
                  class="btn text-lg whitespace-nowrap">new actor</button
                >
              </li>
              <li>
                <button
                  onclick={stopPropagation(preventDefault(adding("client")))}
                  class="btn text-lg whitespace-nowrap">new client</button
                >
              </li>
            </ul>
          </div>
        {/if}
      </div>
    </div>
  </div>

  <div
    class={`dark:bg-black bg-base-300 text-base-content shadow-inner p-6 mb-6`}
  >
    {#if isAdding == "actor"}
      <AddActorComponent cancel={adding(null)} {search} />
    {:else if isAdding == "client"}
      <AddClientComponent cancel={adding(null)} {search} />
    {:else if isConfiguring}
      <SettingsCard />
    {:else if isEditing}
      <button onclick={() => editing(false)}>
        <div class="flex items-center gap-1.5">
          <ChevronLeft size="18" />

          <p>
            back to <span class="italic">search</span>
          </p>
        </div>
      </button>

      {#if isEditing?.actor}
        <ActorCard {...isEditing} editing />
      {:else if isEditing?.client}
        <ClientCard {...isEditing} editing />
      {/if}
    {:else}
      <div class="">
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
        </div>

        {#if !input}
          <div
            class="rounded-lg border-dashed border-2 dark:border-base-300 border-base-100 p-6 mt-6"
          >
            <ul class="opacity-75 gap-3 flex flex-col">
              <li class="flex items-center">
                <span class="grow font-mono">...</span> find a client by its id
              </li>
              <li class="flex items-center">
                <span class="grow font-mono">@...</span> find an actor by nickname
              </li>
              <li class="flex items-center">
                <span class="grow font-mono">@example.com...</span> find an actor
                by email domain
              </li>
              <li class="flex items-center">
                <span class="grow font-mono">email@example.com...</span> find an
                actor by email
              </li>
            </ul>
          </div>
        {:else if isEmpty(result)}
          <div
            class="rounded-lg border-dashed border-2 border-base-300 p-6 mt-3"
          >
            nothing found
          </div>
        {:else}
          {#if result?.actors?.length}
            {#each result.actors as actor (actor.id)}
              <ActorCard {actor} isEditing={editing} />
            {/each}
          {/if}

          {#if result?.clients?.length}
            {#each result.clients as client (client.id)}
              <ClientCard {client} isEditing={editing} />
            {/each}
          {/if}
        {/if}
      </div>
    {/if}
  </div>
</div>
