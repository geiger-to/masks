<script>
  import Avatar from "./Avatar.svelte";
  import PasswordInput from "./PasswordInput.svelte";
  import AddClientComponent from "./AddClientComponent.svelte";
  import AddActorComponent from "./AddActorComponent.svelte";
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
  } from "lucide-svelte";
  import _ from "lodash-es";

  export let nickname;

  let isConfiguring;
  let isAdding;
  let isAddOpen;
  let isIncludeOpen;
  let input;
  let query;
  let result;
  let loading;
  let includeTokens;
  let includeCodes;
  let includeJwts;
  let includeEvents;
  let includeDevices;

  $: query = queryStore({
    client: getContextClient(),
    query: gql`
      query (
        $input: String!
        $jwts: Boolean
        $codes: Boolean
        $tokens: Boolean
        $devices: Boolean
        $events: Boolean
      ) {
        search(
          query: $input
          jwts: $jwts
          codes: $codes
          tokens: $tokens
          devices: $devices
          events: $events
        ) {
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
          events {
            name
            clientId
            actorId
            createdAt
            device {
              id
              name
              deviceType
              deviceName
              osName
              userAgent
              ipAddress
              createdAt
            }
          }
          codes {
            code
            nonce
            scopes
            redirectUri
            createdAt
            expiresAt
          }
          tokens {
            createdAt
            expiresAt
          }
          devices {
            id
            name
            deviceType
            deviceName
            osName
            userAgent
            ipAddress
            createdAt
          }
        }
      }
    `,
    variables: {
      input: input || "",
      tokens: includeTokens,
      codes: includeCodes,
      jwts: includeJwts,
      devices: includeDevices,
      events: includeEvents,
    },
    requestPolicy: "network-only",
  });

  const search = (value) => {
    input = value;
    isAddOpen = false;
    isAdding = false;
    isConfiguring = false;
    isIncludeOpen = false;
  };

  const configuring = () => {
    isAddOpen = false;
    isAdding = false;
    isIncludeOpen = false;
    isConfiguring = !isConfiguring
  }

  const including = () => {
    isIncludeOpen = !isIncludeOpen;
    isAddOpen = false;
    isAdding = false;
  }

  const adding = (name) => {
    return () => {
      isAddOpen = false;
      isConfiguring = false;
      isAdding = name;
    };
  };

  let toggleMenu = () => {
    if (!isAddOpen && !isAdding) {
      isAddOpen = true;
      isAdding = null;
    } else if (isAdding) {
      isAddOpen = false;
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
    return search?.actors?.length == 1 || search?.clients?.length == 1
  };

  let isEmpty = (search) => {
    return (
      search &&
      !search.actors?.length &&
      !search.clients?.length &&
      !search.tokens?.length &&
      !search.codes?.length &&
      !search.jwts?.length &&
      !search.devices?.length &&
      !search.events?.length
    );
  };

  $: autocomplete(input, $query);
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
        on:click|preventDefault|stopPropagation={configuring}
      >
        {#if isConfiguring}
          <X size="20" />
        {:else}
          <Cog size="20" />
        {/if}
      </button>

      <div class={isAddOpen && !isAdding ? `dropdown dropdown-end` : ""}>
        <div
          tabindex="0"
          role="button"
          on:click|preventDefault|stopPropagation={toggleMenu}
          class={`btn ${!isAdding && "focus:btn-success hover:btn-success"} btn-sm px-0 w-8 py-0`}
        >
          {#if isAddOpen || isAdding}
            <X size="20" />
          {:else}
            <PlusSquare size="20" />
          {/if}
        </div>

        {#if isAddOpen}
          <ul
            tabindex="0"
            class="dropdown-content menu bg-white dark:bg-black
        rounded-lg z-[1] p-2 py-1.5 shadow-lg [&>li]:my-1"
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
        {/if}
      </div>

      <Avatar {nickname} onClick={() => search(`@${nickname}`)} />
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
      <div class="flex flex-col gap-3 mb-3">
        <h3 class="font-bold">settings</h3>
        <label class="input input-bordered flex items-center gap-3">
          <span class="label-text opacity-70 w-[60px]">address</span>
          <input
            type="text"
            class="grow ml-3"
            placeholder="e.g. smtp.example.com..."
          />
        </label>
        <label class="input input-bordered flex items-center gap-3">
          <span class="label-text opacity-70 w-[60px]">port</span>
          <input
            type="text"
            class="grow ml-3"
            placeholder="e.g. 25, 465 or 587..."
          />
        </label>
        <label class="input input-bordered flex items-center gap-3">
          <span class="label-text opacity-70 w-[60px]">username</span>
          <input type="text" class="grow ml-3" placeholder="..." />
        </label>
        <PasswordInput label="password" placeholder="..." />
      </div>
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

          <div class={isIncludeOpen ? `dropdown dropdown-end` : "dropdown"}>
            <button
              tabindex="0"
              disabled={!isOneOf(result)}
              type="button"
              class={`btn btn-neutral join-item`}
              on:click|preventDefault|stopPropagation={including}
            >
              {#if isIncludeOpen}
              <X />
              {:else}
              <ListCheck />
              {/if}
            </button>

            <ul
              tabindex="0"
              class={`dropdown-content rounded-lg menu bg-white dark:bg-base-300 mt-1.5 ${!isIncludeOpen ? "hidden" : ""}  rounded-box z-[1] p-2 shadow-lg [&>li]:my-1.5`}
            >
              <li>
                <label class="label cursor-pointer">
                  <input
                    type="checkbox"
                    class="toggle"
                    bind:checked={includeDevices}
                  />
                  <span class="ml-1.5 text-lg font-bold">devices</span>
                </label>
              </li>
              <li>
                <label class="label cursor-pointer">
                  <input
                    type="checkbox"
                    class="toggle"
                    bind:checked={includeEvents}
                  />
                  <span class="text-lg font-bold">events</span>
                </label>
              </li>
              <li>
                <label class="label cursor-pointer">
                  <input
                    type="checkbox"
                    class="toggle"
                    bind:checked={includeCodes}
                  />
                  <span class="text-lg font-bold">codes</span>
                </label>
              </li>
              <li>
                <label class="label cursor-pointer">
                  <input
                    type="checkbox"
                    class="toggle"
                    bind:checked={includeTokens}
                  />
                  <span class="text-lg font-bold">tokens</span>
                </label>
              </li>
              <li>
                <label class="label cursor-pointer">
                  <input
                    type="checkbox"
                    class="toggle"
                    bind:checked={includeJwts}
                  />
                  <span class="text-lg font-bold">jwts</span>
                </label>
              </li>
            </ul>
          </div>
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
        {:else if result?.actors?.length}
          {#each result.actors as actor}
            <ActorCard {actor} />
          {/each}
        {:else if result?.clients?.length}
          {#each result.clients as client}
            <ClientCard {client} />
          {/each}
        {/if}

        <div class="flex flex-col gap-3">
          {#if result?.tokens?.length}
            <div class="">
              <h2 class="font-bold">tokens</h2>
              {#each result?.tokens as token}
                <TokenCard {search} {token} />
              {/each}
            </div>
          {/if}

          {#if result?.codes?.length}
            <div class="">
              <h2 class="font-bold">codes</h2>
              {#each result?.codes as code}
                <CodeCard {search} {code} />
              {/each}
            </div>
          {/if}

          {#if result?.jwts?.length}
            <div class="">
              <h2 class="font-bold">jwts</h2>
              {#each result?.jwts as jwt}
                <JwtCard {search} {jwt} />
              {/each}
            </div>
          {/if}

          {#if result?.devices?.length}
            <div class="">
              <h2 class="font-bold">devices</h2>
              {#each result?.devices as device}
                <DeviceCard {search} {device} />
              {/each}
            </div>
          {/if}

          {#if result?.events?.length}
            <div class="">
              <h2 class="font-bold">events</h2>
              {#each result?.events as event}
                <EventCard {search} {event} />
              {/each}
            </div>
          {/if}
        </div>
      </div>
    {/if}
  </div>
</div>
