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
  } from "lucide-svelte";

  import _ from "lodash-es";
  import { onMount } from "svelte";

  import Time from "./Time.svelte";
  import Alert from "./Alert.svelte";
  import Card from "./Card.svelte";

  export let auth;
  export let authorize;
  export let loading;

  let webauthnOpts;
  let credential;
  let empty;
  let existing = false;

  $: empty = !auth?.actor?.webauthnCredentials?.length;

  let onboard = () => {
    authorize({ event: "webauthn:onboard" });
  };

  $: if (auth?.extras?.webauthn) {
    webauthnOpts = auth?.extras?.webauthn;
  }

  let create = (credential) => {
    authorize({ event: "webauthn:credential", updates: { credential } });
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

  onMount(onboard);
</script>

<Card>
  <div class="flex items-start gap-1.5">
    <div class="grow">
      <div class="flex items-center gap-3 grow py-1">
        <Fingerprint size="20" />
        <div class="grow">
          <div class="text-xs font-bold">Security keys</div>
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
    {#if auth?.actor?.webauthnCredentials?.length}
      {#each auth?.actor?.webauthnCredentials || [] as cred}
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
