<script>
  import { AlertTriangle } from "lucide-svelte";
  import Identicon from "./Identicon.svelte";
  import { onMount } from "svelte";
  import { mutationStore, gql, getContextClient } from "@urql/svelte";
  import Time from "svelte-time";

  export let authId;

  let client = getContextClient();
  let mutation;

  const authorize = ({ nickname, password }) => {
    mutation = mutationStore({
      client,
      query: gql`
        mutation ($input: AuthorizeInput!) {
          authorize(input: $input) {
            errorMessage
            errorCode
            nickname
            authenticated
            authorized
            redirectUri
            actor {
              nickname
              createdAt
              lastLoginAt
            }
            client {
              id
              name
            }
          }
        }
      `,
      variables: { input: { id: authId, nickname, password } },
    });
  };

  let loading;
  let nickname;
  let password;
  let auth;

  const continueAuth = (args) => {
    return (event) => {
      event.preventDefault();

      if (!args.nickname) {
        return;
      }

      authorize(args);
    };
  };

  const updateAuth = (result) => {
    loading = result.fetching;

    if (result.fetching) {
      return;
    }

    auth = result.data.authorize;
    nickname = auth?.nickname;

    if (auth?.authorized && auth.redirectUri) {
      setTimeout(() => {
        window.location.replace(auth.redirectUri);
      }, 100);
    }

    console.log(auth);
  };

  authorize({});

  const ERROR_CODES = {
    invalid_request: "invalid request",
  };

  const ERROR_MESSAGES = {
    invalid_request: (auth) => `cannot login to`,
  };

  $: updateAuth($mutation);
</script>

{#if auth?.errorCode}
  <div class="flex h-full w-full align-items-center items-center">
    <div class="bg-base-300 rounded-xl md:min-w-[500px] mx-auto p-10">
      <div class="flex flex-col mb-5">
        <h1 class="text-error">
          {ERROR_CODES[auth.errorCode]}
        </h1>

        <h2 class="text-black dark:text-white text-2xl">
          {ERROR_MESSAGES[auth.errorCode](auth)}
          <i>{auth?.client?.name}</i>
        </h2>
      </div>

      <button class="btn btn-error"> go back </button>
    </div>
  </div>
{:else}
  <form
    action="#"
    on:submit={continueAuth({ nickname, password })}
    class="flex h-full w-full align-items-center items-center"
  >
    <div class="bold bg-base-300 rounded-xl md:min-w-[500px] mx-auto p-10">
      {#if loading}
        <div class="text-center w-full py-20 opacity-50">
          <div class="loading loading-spinner loading-lg"></div>
        </div>
      {:else}
        <div class="flex flex-col mb-5">
          <h1>
            access {auth?.authorized ? "granted" : "required"}
          </h1>

          <h2 class="text-black dark:text-white text-2xl">
            {auth?.authorized ? "returning" : "login"} to
            <i>{auth?.client?.name}</i>
          </h2>
        </div>

        {#if auth?.authorized}
          <div
            class="flex items-center gap-2.5 mb-5 bg-white dark:bg-black
            p-2.5 rounded-lg shadow
            shadow"
          >
            <div class="avatar">
              <div class="w-12 rounded-full dark:bg-bg-white">
                <Identicon nickname={auth.nickname} />
              </div>
            </div>

            <div>
              <div class="text-xl">
                {auth.nickname}
              </div>

              {#if auth?.actor}
                <div class="text-xs">
                  created

                  <span class="italic">
                    <Time timestamp={auth.actor.createdAt} />
                  </span>
                </div>
              {/if}
            </div>
          </div>

          <div class="flex items-center gap-4 mx-auto text-center">
            <span class="loading loading-dots loading-sm"></span>
            <a href={auth.redirectUri} class="underline">{auth.redirectUri}</a>
          </div>
        {:else}
          <div class="mb-5">
            {#if auth?.nickname}
              <div
                class="flex items-center gap-2.5 mb-2.5 bg-white dark:bg-black
                p-2.5 rounded-lg shadow
                shadow"
              >
                <div class="avatar">
                  <div class="w-12 rounded-full dark:bg-bg-white">
                    <Identicon nickname={auth.nickname} />
                  </div>
                </div>

                <div>
                  <div class="text-xl">
                    {auth.nickname}
                  </div>

                  {#if auth?.actor}
                    <div class="text-xs">
                      last login

                      <span class="italic">
                        {#if auth.actor.lastLoginAt}
                          <Time timestamp={auth.actor.lastLoginAt} />
                        {:else}
                          never
                        {/if}
                      </span>
                    </div>
                  {/if}
                </div>
              </div>
            {:else if !auth?.nickname}
              <input
                autofocus
                class="w-full input input-lg"
                placeholder="enter your nickname..."
                type="text"
                bind:value={nickname}
              />
            {/if}

            {#if auth?.nickname}
              <input
                autofocus
                class="w-full input input-lg"
                placeholder="enter your password..."
                type="password"
                bind:value={password}
              />
            {/if}
          </div>

          <div class="flex items-center gap-5">
            <input type="submit" class="btn btn-primary" value="continue" />

            {#if auth?.error}
              <div class="text-xs text-error flex items-center gap-2">
                <AlertTriangle size="15" />

                <div>
                  {auth.error}...
                </div>
              </div>
            {:else}
              <span class="text-xs">
                to

                {#if !auth?.nickname}
                  enter your password...
                {:else}
                  <a
                    href={auth.redirectUri}
                    class="text-xs underline"
                    target="_blank"
                  >
                    {auth.redirectUri}</a
                  >...
                {/if}
              </span>
            {/if}
          </div>
        {/if}
      {/if}
    </div>
  </form>
{/if}
