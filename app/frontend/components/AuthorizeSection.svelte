<script>
  import { AlertTriangle, RotateCcw } from "lucide-svelte";
  import Identicon from "./Identicon.svelte";
  import PasswordInput from "./PasswordInput.svelte";
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

  const startOver = () => {
    auth.nickname = null;
    auth.errorCode = null;
    auth.errorMessage = null;
    nickname = null;
    password = null;
  };

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
  };

  authorize({});

  $: updateAuth($mutation);
</script>

{#if auth?.errorCode == "invalid_request"}
  <div class="flex h-full w-full align-items-center items-center">
    <div class="bg-base-300 rounded-xl md:min-w-[500px] mx-auto p-10">
      <div class="flex flex-col mb-5">
        <h1 class="text-error">invalid request</h1>

        <h2 class="text-black dark:text-white text-2xl">
          cannot login to
          <i>{auth?.client?.name}</i>
        </h2>
      </div>

      <button class="btn btn-error"> go back </button>
    </div>
  </div>
{:else if !auth}
  <div class="flex h-full w-full align-items-center items-center">
    <div class="bg-base-300 rounded-xl md:min-w-[500px] mx-auto p-10">
      <div class="flex flex-col my-10">
        <span class="loading loading-spinner loading-lg mx-auto"></span>
      </div>
    </div>
  </div>
{:else if auth}
  <form
    action="#"
    on:submit={continueAuth({ nickname, password })}
    class="flex h-full w-full align-items-center items-center"
  >
    <div class="bold bg-base-300 rounded-xl md:min-w-[500px] mx-auto p-10">
      <div class="flex flex-col mb-5">
        <h1>
          access {auth?.authorized ? "granted" : "required"}
        </h1>

        <h2 class="text-black dark:text-white text-2xl">
          {auth?.authorized ? "returning" : "login"} to
          <i>{auth?.client?.name || "..."}</i>
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

              <div class="text-xl grow">
                {auth.nickname}
              </div>

              <button
                type="button"
                class="btn btn-ghost"
                alt="start over"
                on:click|stopPropagation|preventDefault={startOver}
              >
                <RotateCcw />
              </button>
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
            <PasswordInput
              class="input-lg"
              placeholder="enter your password..."
              bind:value={password}
            />
          {/if}
        </div>

        <div class="flex items-center gap-5">
          <button
            type="submit"
            class="btn btn-primary w-[100px] text-center"
            disabled={loading || !nickname || (auth?.nickname && !password)}
            value="continue"
          >
            {#if loading}
              <span class="loading loading-spinner loading-md mx-auto"></span>
            {:else}
              continue
            {/if}
          </button>

          {#if auth?.errorCode}
            <div class="text-sm text-error flex items-center gap-2">
              <AlertTriangle size="15" />

              <div>
                {auth.errorMessage}...
              </div>
            </div>
          {:else if auth?.nickname}
            <span class="text-sm">
              to
              <a
                href={auth.redirectUri}
                class="text-sm underline"
                target="_blank"
              >
                {auth.redirectUri.slice(0, 40)}</a
              >...
            </span>
          {/if}
        </div>
      {/if}
    </div>
  </form>
{/if}
