<script>
  import { TokenFragment } from "@/util.js";
  import { route } from "@mateothegreat/svelte5-router";
  import {
    X,
    Trash2 as Trash,
    LogIn,
    User,
    Handshake,
    Search,
    ChevronDown,
    ChevronRight,
  } from "lucide-svelte";
  import EditableImage from "@/components/EditableImage.svelte";
  import DeviceIcon from "@/components/DeviceIcon.svelte";
  import Identicon from "@/components/Identicon.svelte";
  import Time from "@/components/Time.svelte";
  import { queryStore, gql, getContextClient } from "@urql/svelte";
  import QuerySearch from "@/components/QuerySearch.svelte";
  import PaginateSearch from "@/components/PaginateSearch.svelte";
  import CopyText from "@/components/CopyText.svelte";
  import Mutation from "@/components/Mutation.svelte";
  import Deletion from "./Deletion.svelte";

  const LogoutMutation = gql`
    mutation ($input: TokenInput!) {
      token(input: $input) {
        token {
          ...TokenFragment
        }
        errors
      }
    }

    ${TokenFragment}
  `;

  let { token, ...props } = $props();
  let opened = $state(false);
  let device = (token) => {
    return props.device || token.device;
  };

  let ICONS = {
    "Internal token": {
      icon: LogIn,
    },
    "Access token": {
      icon: User,
    },
    "Client token": {
      icon: Handshake,
    },
  };
</script>

<Deletion
  type="Token"
  id={token.id}
  confirm="Are you sure you want to delete this token?"
>
  {#snippet children({ deletion, deleting, deleted, errors })}
    <div class={`bg-base-100 rounded-lg px-3 max-w-full ${props.class}`}>
      <div class="flex items-center gap-1.5 w-full">
        <a
          use:route
          href={`/manage/actor/${token.actor.id}`}
          class="
          -ml-1
          truncate
          flex items-center gap-1.5
          hover:underline focus:underline"
        >
          <div class="min-w-6 w-6 h-6 bg-black rounded p-[1px] my-1.5">
            <Identicon id={token.actor.identiconId} />
          </div>

          <span
            class="truncate
          font-bold text-sm">{token.actor.name || token.actor.identifier}</span
          >
        </a>

        <ChevronRight size="10" />

        <a
          use:route
          class="truncate text-sm hover:underline focus:underline"
          href={`/manage/client/${token.client.id}`}
          >{token.client.name || token.client.key}</a
        >

        {#if device(token)}
          <a
            class="opacity-75"
            use:route
            title={`${device(token).name} on ${device(token).os}`}
            href={`/manage/device/${device(token).id}`}
          >
            <DeviceIcon size="14" device={device(token)} />
          </a>
        {/if}

        <div class="grow"></div>
        <div class="flex items-center gap-3">
          <div class={`truncate text-xs opacity-75 flex items-center gap-3`}>
            {#if ICONS[token.type]}
              {@const Icon = ICONS[token.type].icon}
              <Icon size="12" />
            {/if}

            <span
              class={`${deleted || token.expired ? "text-error" : token.revokedAt ? "text-warning" : "text-success"} opacity-75`}
            >
              {#if deleted}
                deleted
              {:else if token.usable}
                expires
                <Time relative timestamp={token.expiresAt} />
              {:else if token.expired}
                expired
                <Time relative timestamp={token.expiresAt} />
              {:else if token.revokedAt}
                revoked
                <Time relative timestamp={token.revokedAt} />
              {/if}
            </span>
          </div>

          <button
            class="btn btn-xs btn-square"
            onclick={() => (opened = !opened)}
          >
            {#if opened}
              <X size="14" />
            {:else}
              <ChevronDown size="14" />
            {/if}
          </button>
        </div>
      </div>

      {#if opened}
        <div class="-my-1.5 pb-3">
          <div class="divider my-0"></div>

          <div
            class="flex items-center gap-1.5 w-full mb-1.5 bg-base-300 p-1.5 pl-3 rounded-lg"
          >
            <div class="truncate text-xs opacity-75 grow">
              {token.type} created <Time relative timestamp={token.createdAt} />
            </div>

            {#if !deleted && !token.expired}
              <Mutation
                key="token"
                query={LogoutMutation}
                input={{ id: token.id }}
                confirm={`Are you sure you want to ${token.revokedAt ? "restore" : "revoke"} this token?`}
              >
                {#snippet children({ mutate, mutating })}
                  <button
                    class={`btn btn-xs ${token.revokedAt ? "btn-neutral" : "btn-warning"}`}
                    onclick={() =>
                      mutate({ revoked: token.revokedAt ? false : true })}
                  >
                    {token.revokedAt ? "restore" : "revoke"}
                  </button>
                {/snippet}
              </Mutation>
            {/if}

            <button
              class="btn btn-xs btn-error"
              onclick={deletion}
              disabled={deleting || deleted}
            >
              {#if deleting}
                <span class="loading loading-spinnner"></span>
              {:else if deleted}
                deleted
              {:else}
                delete
              {/if}
            </button>
          </div>

          <div class="flex flex-col gap-1.5 p-1.5">
            <CopyText
              labelClass="min-w-[60px]"
              label="identifier"
              text={token.id}
            />
            <CopyText
              labelClass="min-w-[60px]"
              label="secret"
              text={token.secret}
            />
            <CopyText
              labelClass="min-w-[60px]"
              label="redirect"
              text={token.redirectUri}
            />
            <CopyText
              labelClass="min-w-[60px]"
              label="scopes"
              text={token.scopes.join(" ")}
            />

            {#if token.nonce}
              <CopyText
                labelClass="min-w-[60px]"
                label="nonce"
                text={token.nonce}
              />
            {/if}
          </div>
        </div>
      {/if}
    </div>
  {/snippet}
</Deletion>
