<script>
  import { run, preventDefault, stopPropagation } from "svelte/legacy";

  import Avatar from "../components/Avatar.svelte";
  import PasswordInput from "../components/PasswordInput.svelte";
  import AddClientComponent from "../components/AddClientComponent.svelte";
  import AddActorComponent from "../components/AddActorComponent.svelte";
  import SettingsCard from "../components/SettingsCard.svelte";
  import EventCard from "../components/EventCard.svelte";
  import DeviceCard from "../components/DeviceCard.svelte";
  import TokenCard from "../components/TokenCard.svelte";
  import CodeCard from "../components/CodeCard.svelte";
  import JwtCard from "../components/JwtCard.svelte";
  import ClientCard from "../components/ClientCard.svelte";
  import ActorCard from "../components/ActorCard.svelte";
  import Identicon from "../components/Identicon.svelte";
  import HomePage from "./HomePage.svelte";
  import SettingsPage from "./SettingsPage.svelte";
  import ActorResult from "./ActorResult.svelte";
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
  import { Router, Link, Route } from "svelte-routing";

  /**
   * @typedef {Object} Props
   * @property {any} actor
   * @property {string} [url]
   */

  /** @type {Props} */
  let { actor, url = "" } = $props();
  let { nickname } = actor;
  let isAddOpen = $state();
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
      variables,
      requestPolicy: "network-only",
    })
  );

  let result = $state();
  let loading = $state();
  let variables = $state({ input: "" });
  let client = getContextClient();

  let search = (value) => {
    isAddOpen = false;
    input = value;
    variables = { input };
  };

  let toggleMenu = () => {
    if (isAddOpen) {
      isAddOpen = false;
    } else {
      isAddOpen = true;
    }
  };

  let autocomplete = (i, query) => {
    if (i) {
      loading = true;

      if (query?.data?.search) {
        result = query?.data?.search;
        loading = false;
      }
    }
  };

  let isSearching = $state();

  let toggleSearch = (current) => {
    return () => {
      isSearching = !current;
      isAddOpen = false;
    };
  };

  let openSearch = () => {
    isSearching = true;
    isAddOpen = false;
  };

  let closeSearch = () => {
    isSearching = false;
    isAddOpen = false;
  };

  let debounceInput = _.debounce((e) => {
    if (!e.target.value) {
      return;
    }

    variables = { input: e.target.value };
  }, 500);

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

<Router {url} basepath="manage">
  <div class={`bg-base-300 h-full group ${isSearching ? "is-searching" : ""}`}>
    <div class="navbar bg-base-200 my-0 min-h-0">
      <div
        class="navbar-start group-[.is-searching]:hidden md:group-[.is-searching]:flex"
      >
        <div class="text-lg font-bold ml-4 text-black dark:text-white">
          <Link to={"/manage"}>masks</Link>
        </div>
      </div>

      <div class="flex items-center join grow w-full">
        <label
          class="input input-sm input-ghost items-center gap-3 grow w-full
            join-item hidden md:flex group-[.is-searching]:flex"
        >
          {#if loading}
            <span class="loading loading-spinner"></span>
          {:else}
            <Search />
          {/if}

          <input
            type="text"
            class="grow w-full"
            placeholder="search..."
            bind:value={input}
            oninput={debounceInput}
          />

          {#if isSearching}
            <button
              tabindex="0"
              onclick={stopPropagation(preventDefault(closeSearch))}
              class={`btn btn-xs px-0 w-6 py-0 md:hidden`}
            >
              <X size="20" />
            </button>
          {/if}
        </label>
      </div>

      <div
        class="navbar-end pr-3 flex items-center gap-1 group-[.is-searching]:hidden md:group-[.is-searching]:flex"
      >
        <div
          class={`dropdown ${isAddOpen ? "dropdown-open" : ""} dropdown-bottom dropdown-end md:dropdown-left flex items-center gap-1`}
        >
          <button
            tabindex="0"
            onclick={stopPropagation(preventDefault(toggleSearch(isSearching)))}
            class={`btn btn-sm px-0 w-8 py-0 md:hidden`}
          >
            {#if isAddOpen}
              <X size="20" />
            {:else}
              <Search size="20" />
            {/if}
          </button>

          <button
            tabindex="0"
            onclick={stopPropagation(preventDefault(toggleMenu))}
            class={`btn btn-sm px-0 w-8 py-0 ${isAddOpen ? "btn-success" : "btn-ghost"}`}
          >
            {#if isAddOpen}
              <X size="20" />
            {:else}
              <PlusSquare size="20" />
            {/if}
          </button>

          <Link to={"settings"}>
            <p class={`btn btn-sm px-0 w-8 btn-ghost`}>
              <Cog size="20" />
            </p>
          </Link>

          {#if isAddOpen}
            <div
              class="dropdown-content mr-1.5 flex items-center p-1 gap-1
        rounded-lg z-[1] shadow-lg bg-success mt-[5px] md:mt-0"
            >
              <Link
                to="actor"
                class="btn btn-neutral join-item btn-xs whitespace-nowrap"
                >new actor</Link
              >
              <Link
                to="client"
                class="btn btn-neutral join-item btn-xs whitespace-nowrap"
                >new client</Link
              >
            </div>
          {/if}
        </div>

        <Link to={`actor/${actor.identifier}`} class="w-[31px] h-[31px] ml-1.5">
          <Avatar {actor} />
        </Link>
      </div>
    </div>

    <div class={`bg-base-300 text-base-content shadow-inner p-6 mb-6`}>
      <Route path="settings" component={SettingsPage} />
      <Route path="/" component={HomePage} />
    </div>
  </div>

  <div class={`w-full grow ${isSearching ? "animate-fade-in-fast" : "hidden"}`}>
    <div
      class="absolute w-full shadow-xl bg-base-100 left-0 right-0 top-[48px] p-6 shadow-inner"
    >
      {#if !input}
        <div
          class="rounded-lg border-dashed border-2 dark:border-base-300 border-base-100 p-6"
        >
          <ul class="opacity-75 gap-3 flex flex-col text-xs md:text-base">
            <li class="flex items-center truncate gap-3">
              <span class="grow font-mono">...</span> find a client by its id
            </li>
            <li class="flex items-center truncate gap-3">
              <span class="grow font-mono">@...</span> find an actor by nickname
            </li>
            <li class="flex items-center truncate gap-3">
              <span class="grow font-mono">@example.com...</span> find an actor by
              email domain
            </li>
            <li class="flex items-center truncate gap-3">
              <span class="grow font-mono">email@example.com...</span> find an actor
              by email
            </li>
          </ul>
        </div>
      {:else if isEmpty(result)}
        <div class="rounded-lg border-dashed border-2 border-base-300 p-6 mt-3">
          nothing found
        </div>
      {:else}
        {#if result?.actors?.length}
          {#each result.actors as actor (actor.id)}
            <ActorResult {actor} />
          {/each}
        {/if}

        {#if result?.clients?.length}
          {#each result.clients as client (client.id)}
            <ClientCard {client} />
          {/each}
        {/if}
      {/if}
    </div>
  </div>
</Router>
