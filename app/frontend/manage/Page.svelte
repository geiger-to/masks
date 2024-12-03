<script>
  import { route } from "@mateothegreat/svelte5-router";
  import { run, preventDefault, stopPropagation } from "svelte/legacy";
  import Avatar from "../components/Avatar.svelte";
  import PasswordInput from "../components/PasswordInput.svelte";
  import SettingsCard from "../components/SettingsCard.svelte";
  import DeviceCard from "../components/DeviceCard.svelte";
  import TokenCard from "../components/TokenCard.svelte";
  import CodeCard from "../components/CodeCard.svelte";
  import JwtCard from "../components/JwtCard.svelte";
  import Identicon from "../components/Identicon.svelte";
  import HomePage from "./HomePage.svelte";
  import SettingsPage from "./SettingsPage.svelte";
  import ActorResult from "./ActorResult.svelte";
  import ClientResult from "./ClientResult.svelte";
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

  /**
   * @typedef {Object} Props
   * @property {any} actor
   * @property {string} [url]
   */

  /** @type {Props} */
  let { actor, children, url = "", loading = false } = $props();
  let { nickname } = actor;
  let isAddOpen = $state();
  let input = $state();
  let variables = $state({ input: "" });
  let result = $state();
  let isLoading = $state();
  let client = getContextClient();
  let query = $derived(
    queryStore({
      client: getContextClient(),
      query: gql`
        query ($input: String!) {
          search(query: $input) {
            actors {
              id
              nickname
              identifier
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

  let search = (value) => {
    isAddOpen = false;
    input = value;
  };

  let toggleMenu = () => {
    if (isAddOpen) {
      isAddOpen = false;
    } else {
      isAddOpen = true;
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

  let blurSearch = () => {
    if (!input) {
      closeSearch();
    }
  };

  let closeSearch = () => {
    isSearching = false;
    isAddOpen = false;
  };

  let handleKey = (e) => {
    if (e.key == "Escape" || (e.key == "Backspace" && !input)) {
      e.preventDefault();
      e.stopPropagation();

      closeSearch();
    }
  };

  let debounceInput = _.debounce((e) => {
    isSearching = true;

    if (!e.target.value) {
      return;
    }

    isLoading = true;
    variables = { input: e.target.value };

    query.subscribe(searchResponse);
  }, 300);

  let isOneOf = (search) => {
    return search?.actors?.length == 1 || search?.clients?.length == 1;
  };

  let isEmpty = (search) => {
    return search && !search.actors?.length && !search.clients?.length;
  };

  let searchResponse = (response) => {
    isLoading = !response?.data || response?.fetching;

    if (response?.data?.search) {
      result = response?.data?.search;
    }
  };

  let navbar;
</script>

<div class={`bg-base-300 h-full group ${isSearching ? "is-searching" : ""}`}>
  <div bind:this={navbar}>
    <div class="navbar bg-base-200 my-0 min-h-0">
      <div
        class="navbar-start group-[.is-searching]:hidden md:group-[.is-searching]:flex"
      >
        <div class="text-lg font-bold ml-4 text-black dark:text-white">
          <a use:route href={"/manage"}>masks</a>
        </div>
      </div>

      <div class="flex items-center join grow w-full">
        <label
          class="input input-sm input-ghost items-center gap-3 grow w-full
                join-item hidden md:flex group-[.is-searching]:flex"
        >
          <div>
            {#if isLoading}
              <span class="loading loading-spinner"></span>
            {:else}
              <Search />
            {/if}
          </div>

          <input
            type="text"
            class="grow w-full"
            placeholder="search..."
            bind:value={input}
            oninput={debounceInput}
            onfocus={openSearch}
            onblur={blurSearch}
            onkeydown={handleKey}
          />

          {#if isSearching}
            <button
              tabindex="0"
              onclick={stopPropagation(preventDefault(closeSearch))}
              class={`btn btn-xs px-0 w-6 py-0 -mr-1.5`}
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

          <a use:route href={"/manage/settings"}>
            <p class={`btn btn-sm px-0 w-8 btn-ghost`}>
              <Cog size="20" />
            </p>
          </a>

          {#if isAddOpen}
            <div
              class="dropdown-content mr-1.5 flex items-center p-1 gap-1
            rounded-lg z-50 shadow-lg bg-success mt-[5px] md:mt-0"
            >
              <a
                use:route
                href="/manage/actor"
                class="btn btn-neutral join-item btn-xs whitespace-nowrap"
                >new actor</a
              >
              <a
                use:route
                href="/manage/client"
                class="btn btn-neutral join-item btn-xs whitespace-nowrap"
                >new client</a
              >
            </div>
          {/if}
        </div>

        <a
          use:route
          href={`/manage/actor/${actor.identifier}`}
          class="w-[31px] h-[31px] ml-1.5"
        >
          <Avatar {actor} />
        </a>
      </div>
    </div>

    <div
      class={`w-full grow ${isSearching ? "animate-fade-in-fast" : "hidden"}`}
    >
      <div
        class="z-50 absolute w-full shadow-xl bg-base-100 left-0 right-0 top-[48px] p-6 shadow-inner"
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
                <span class="grow font-mono">@example.com...</span> find an actor
                by email domain
              </li>
              <li class="flex items-center truncate gap-3">
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
          {#key input}
            {#if result?.actors?.length}
              <div class="flex flex-col gap-1.5">
                {#each result.actors as actor (actor.id)}
                  <ActorResult {actor} />
                {/each}
              </div>
            {/if}
          {/key}

          {#if result?.clients?.length}
            {#each result.clients as client (client.id)}
              <ClientResult {client} />
            {/each}
          {/if}
        {/if}
      </div>
    </div>
  </div>

  <div class={`bg-base-300 text-base-content shadow-inner p-1.5 md:p-6 mb-6`}>
    {#if isLoading || loading}
      <div class="flex flex-col gap-4">
        <div class="flex items-center gap-4">
          <div class="skeleton h-16 w-16 shrink-0 rounded-lg"></div>
          <div class="flex flex-col gap-4 grow">
            <div class="skeleton h-4 w-1/2"></div>
            <div class="skeleton h-4 w-2/3"></div>
          </div>
        </div>
        <div class="skeleton h-4 w-full"></div>
        <div class="skeleton h-8 w-full"></div>
      </div>
    {:else}
      {@render children?.()}
    {/if}
  </div>
</div>
