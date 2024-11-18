{#if isAdding == "actor"}
  <AddActorComponent cancel={adding(null)} {search} />
{:else if isAdding == "client"}
  <AddClientComponent cancel={adding(null)} {search} />
{:else if isConfiguring}
  <SettingsCard />
{:else if isEditing}
  <button on:click={() => editing(false)}>
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
          on:input={debounceInput}
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
            <span class="grow font-mono">@example.com...</span> find an actor by
            email domain
          </li>
          <li class="flex items-center">
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
