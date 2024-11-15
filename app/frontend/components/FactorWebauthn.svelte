<script>
  import "web-streams-polyfill/polyfill";
  import * as WebAuthnJSON from "@github/webauthn-json/browser-ponyfill";

  import {
    Check,
    Trash2 as Trash,
    Binary,
    QrCode,
    Phone,
    Fingerprint,
    AlertTriangle,
    ChevronDown,
    Info,
  } from "lucide-svelte";

  import _ from "lodash-es";
  import { onMount } from "svelte";

  import Time from "./Time.svelte";
  import Alert from "./Alert.svelte";
  import Card from "./Card.svelte";
  import AaguidIcon from "./AaguidIcon.svelte";
  import Dropdown from "./Dropdown.svelte";

  export let auth;
  export let authorize;
  export let authorizing;
  export let loading;

  let webauthnOpts;
  let credential;
  let credentials;
  let empty;
  let existing = false;

  $: credentials = auth?.actor?.secondFactors?.filter(
    (f) => f.__typename == "WebauthnCredential"
  );
  $: empty = !credentials?.length;

  let add = () => {
    authorize({ event: "webauthn:add" });
  };

  let create = (credential) => {
    authorize({ event: "webauthn:verify", updates: { credential } }).then(add);
  };

  let setUp = (opts) => {
    existing = false;

    return () => {
      WebAuthnJSON.create(
        WebAuthnJSON.parseCreationOptionsFromJSON({ publicKey: opts })
      )
        .then(create)
        .catch((e) => {
          if (e.code == e.INVALID_STATE_ERR) {
            existing = true;
          }
        });
    };
  };

  let init = () => {
    authorize({ event: "webauthn:init" });
  };

  let authenticate = (credential) => {
    authorize({ event: "webauthn:auth", updates: { credential } });
  };

  let verify = (opts) => {
    return () => {
      WebAuthnJSON.get(
        WebAuthnJSON.parseRequestOptionsFromJSON({ publicKey: opts })
      )
        .then(authenticate)
        .catch(console.log);
    };
  };

  $: if (auth?.extras?.webauthn) {
    webauthnOpts = auth?.extras?.webauthn;
  }

  $: if (authorizing && credentials) {
    credential = credentials[0];
  }

  let dropdown;

  let chooseCred = (c) => {
    return () => {
      credential = c;

      if (dropdown) {
        dropdown.open = false;
      }
    };
  };

  onMount(authorizing ? init : add);
</script>

{#if authorizing}
  <Alert type="primary">
    <div class="flex items-center gap-1.5 mb-1.5">
      <Dropdown value={credential}>
        <summary
          slot="summary"
          class="flex items-center gap-0.5 btn btn-xs bg-primary-content border-primary-content text-primary pl-0.5 rounded"
        >
          {#if credentials?.length > 1}
            {#each credentials as cred}
              <AaguidIcon icons={cred.icons} />
            {/each}

            <span class="pl-1.5">{credentials.length} keys</span>
            <ChevronDown size="16" />
          {:else}
            <AaguidIcon icons={credential?.icons} />

            <div class="truncate max-w-[175px] pl-1.5">
              {credential?.name}
            </div>
          {/if}
        </summary>

        <div slot="dropdown">
          {#if credentials?.length > 1}
            <ul class="">
              {#each credentials as c}
                <li
                  class="p-1.5 flex items-center gap-3 text-sm font-bold text-neutral-content"
                >
                  <AaguidIcon icons={c?.icons} />
                  <span class="truncate">{c.name}</span>
                </li>
              {/each}
            </ul>
          {:else if !empty}
            <div class="text-xs whitespace-nowrap flex items-center gap-1.5">
              <Info size="16" />
              <span>
                You added this key <Time timestamp={credential?.createdAt} />.
              </span>
            </div>
          {/if}
        </div>
      </Dropdown>
    </div>

    <button
      class="btn btn-primary w-full btn-lg mb-1.5"
      disabled={!webauthnOpts}
      on:click|preventDefault|stopPropagation={verify(webauthnOpts)}
    >
      <Fingerprint size="20" /> verify
    </button>
  </Alert>
{:else}
  <Card>
    <div class="flex items-start gap-1.5">
      <div class="grow">
        <div class="flex items-center gap-3 grow py-1">
          <Fingerprint size="20" />
          <div class="grow">
            <div class="text-xs font-bold">Security key</div>
          </div>
        </div>

        {#if empty}
          <div class="text-sm opacity-75 mb-1.5">
            Add a hardware-based key, like a YubiKey or fingerprint sensor.
          </div>
        {/if}
      </div>
    </div>

    {#if existing}
      <Alert type="warn" icon={AlertTriangle}>
        You've already added this security key...
      </Alert>
    {/if}

    <div class="flex flex-col gap-1.5 my-1.5">
      {#if !empty}
        {#each credentials || [] as cred}
          <div class="bg-base-100 rounded-lg p-1.5">
            <div class="flex items-center gap-1.5">
              <div
                class="text-black dark:text-white grow ml-1.5 whitespace-nowrap"
              >
                {cred.name}
              </div>

              <span class="text-xs whitespace-nowrap opacity-75"
                ><Time ago="old" timestamp={cred.createdAt} /></span
              >

              <button type="button" class="btn btn-xs text-error m-0 p-0 px-1">
                <Trash size="15" />
              </button>
            </div>
          </div>
        {/each}
      {/if}
    </div>

    <button
      type="button"
      class={"btn btn-sm w-full"}
      disabled={!webauthnOpts}
      on:click|preventDefault|stopPropagation={setUp(webauthnOpts)}
    >
      {empty ? "add your key" : "add another key"}
    </button>
  </Card>
{/if}
