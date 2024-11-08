<script>
  import "web-streams-polyfill/polyfill";
  import * as WebAuthnJSON from "@github/webauthn-json/browser-ponyfill";
  import Time from 'svelte-time'

  import _ from "lodash-es";

  import { Trash2 as Trash, Binary, QrCode, Phone, Fingerprint } from "lucide-svelte";

  import { onMount } from "svelte";

  export let auth;
  export let authorize;

  let webauthnOpts;
  let credential;

  let onboard = () => {
    authorize({ event: "webauthn:onboard" });
  };

  $: if (auth?.extras?.webauthn) {
    webauthnOpts = auth?.extras?.webauthn;
  }

  let create = (credential) => {
    authorize({ event: "webauthn:credential", updates: { credential }});
  }

  let setUp = (opts) => {
    return () => {
      WebAuthnJSON.create(WebAuthnJSON.parseCreationOptionsFromJSON({publicKey: opts})).then(create)
    }
  };

  onMount(onboard);
</script>

<div class="bg-base-100 rounded-lg p-3 pt-1.5">
  <div class="flex items-center gap-3 pl-1.5">
    <Fingerprint size="18" class={credential ? "text-success" : ""} />

    <div class="grow">
      <div class="text-xs">Hardware keys</div>
    </div>

    <button
      class="btn btn-xs"
      disabled={!webauthnOpts}
      on:click|preventDefault|stopPropagation={setUp(webauthnOpts)}
    >
      add a key
    </button>
  </div>

  <div class="divider my-0 mb-1.0 opacity-75" />

  <div class="flex flex-col gap-1.5 pl-1.5">
    {#each auth?.actor?.webauthnCredentials || [] as cred}
      <div class="flex items-baseline gap-3">
        <div class="text-sm font-bold">
          {cred.name}
        </div>

        <span class="text-xs grow truncate">added <Time relative timestamp={cred.createdAt} /></span>

        <button class="btn btn-xs btn-link !text-error">
          <Trash size="14" />
        </button>
      </div>
    {/each}
  </div>
</div>
