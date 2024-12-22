<script>
  import _ from "lodash-es";
  import {
    Info,
    X,
    Share2,
    Fingerprint,
    Check,
    Palette,
    AlertTriangle as AlertIcon,
  } from "lucide-svelte";
  import Page from "./Page.svelte";
  import ScopesEditor from "./ScopesEditor.svelte";
  import ChecksEditor from "./ChecksEditor.svelte";
  import ClientResult from "./ClientResult.svelte";
  import Alert from "@/components/Alert.svelte";
  import EditableImage from "@/components/EditableImage.svelte";
  import PasswordInput from "@/components/PasswordInput.svelte";
  import Time from "@/components/Time.svelte";
  import {
    mutationStore,
    queryStore,
    gql,
    getContextClient,
  } from "@urql/svelte";

  let { params, grapqhl, ...props } = $props();
  let graphql = getContextClient();
  let clientFragment = gql`
    fragment ClientFragment on Client {
      id
      secret
      checks
      scopes
      redirectUris
      subjectType
      name
      type
      logo
      bgLight
      bgDark
      sectorIdentifier
      pairwiseSalt
      allowPasswords
      allowLoginLinks
      autofillRedirectUri
      fuzzyRedirectUri
      codeExpiresIn
      idTokenExpiresIn
      accessTokenExpiresIn
      refreshExpiresIn
      loginLinkExpiresIn
      authAttemptExpiresIn
      emailVerificationExpiresIn
      loginLinkFactorExpiresIn
      passwordFactorExpiresIn
      secondFactorBackupCodeExpiresIn
      secondFactorPhoneExpiresIn
      secondFactorTotpCodeExpiresIn
      secondFactorWebauthnExpiresIn
      internalSessionExpiresIn
      lifetimeTypes
      createdAt
      updatedAt
    }
  `;
  let query = $derived(
    queryStore({
      client: graphql,
      query: gql`
        query ($id: ID!) {
          client(id: $id) {
            ...ClientFragment
          }
          install {
            checks
            clients
          }
        }

        ${clientFragment}
      `,
      variables: { id: params[0] },
      requestPolicy: "network-only",
    })
  );

  let saving = $state(false);

  let save = () => {
    query.pause();

    saving = true;

    let update = mutationStore({
      client: graphql,
      query: gql`
        mutation ($input: ClientInput!) {
          client(input: $input) {
            client {
              ...ClientFragment
            }

            errors
          }
        }

        ${clientFragment}
      `,
      variables: { input: { ...changes, id: client.id } },
    });

    update.subscribe((r) => {
      errors = r?.data?.client?.errors;
      errors = errors?.length ? errors : null;
      saving = r?.fetching;

      if (!saving && !errors) {
        changes = {};
        original = client = r?.data?.client?.client;
        loading = false;
      }
    });
  };

  let result = $state({ data: {} });
  let client = $state();
  let settings = $derived(result?.data?.install);
  let changes = $state({});
  let errors = $state();
  let original = $state(false);
  let loading = $state(true);
  let theming = $state(false);
  let tab = $state(false);

  let subscribe = () => {
    query.subscribe((r) => {
      result = r;
      client = r?.data?.client;
      original = original || client;
      loading = r.fetching;
    });
  };

  subscribe();

  let change = (obj) => {
    changes = { ...changes, ...obj };
    client = { ...client, ...changes };
  };

  let isChanged = () => {
    return !_.isEqual(original, client);
  };

  let reset = () => {
    errors = null;
    client = original;
    changes = {};
  };

  let subjectTypes = {
    "public-uuid": {
      name: "UUID",
      desc: "Actors are distinguished by a globally unique ID...",
    },
    "public-identifier": {
      name: "Identifier",
      desc: "Actor IDs will include their unique nickname or login email...",
    },
    "pairwise-uuid": {
      name: "Masked UUID",
    },
  };
</script>

{#key client?.updatedAt}
  <Page {...props} loading={loading || !client}>
    <ClientResult {client} {change} class="mb-3">
      {#snippet after()}
        <div class="flex flex-col items-center pr-1.5">
          <button
            class="btn btn-sm btn-success"
            disabled={saving || loading || !isChanged()}
            type="button"
            onclick={save}><Check size="20" /></button
          >
          <button
            class={`btn btn-xs text-error btn-link ${isChanged() ? "" : "opacity-0"}`}
            type="button"
            disabled={!isChanged()}
            onclick={reset}>reset</button
          >
        </div>
      {/snippet}
    </ClientResult>

    {#if errors}
      <Alert type="error" class="mb-3" icon={AlertIcon}>
        <ul class="list-disc ml-3">
          {#each errors as error}
            <li class="ml-1.5">{error}</li>
          {/each}
        </ul>
      </Alert>
    {/if}

    <div class="flex items-center gap-1.5 bg-base-200 mb-3 rounded-lg pr-3">
      <div class="">
        <select
          class="select select-sm join-item rounded-r-none leading-snug"
          onchange={(e) => change({ type: e.target.value })}
        >
          {#each settings?.clients?.types as type}
            <option selected={type == client?.type}>{type}</option>
          {/each}
        </select>
      </div>

      <button
        class="btn btn-xs btn-neutral border-none text-white mr-1 rounded-full px-1"
        type="button"
        onclick={() => (tab = tab == "theme" ? null : "theme")}
        >{#if tab == "theme"}<X size="16" />{:else}<Palette
            size="16"
            class=""
          />{/if}</button
      >

      <div class="grow"></div>

      <span class="text-xs opacity-50 whitespace-nowrap">
        saved
        <Time timestamp={client.updatedAt} />
      </span>
    </div>

    {#if tab == "theme"}
      <div class="flex flex-col gap-1.5 mb-3">
        <div
          class="flex items-start gap-3 textarea textarea-bordered p-3 pb-2"
          data-theme="light"
        >
          <div
            class="w-20 h-20 rounded bg-white shadow"
            style={client.bgLight}
          ></div>

          <div class="grow">
            <p class="text-xs opacity-75 mb-1.5">light background (css)</p>
            <textarea
              class="bg-transparent font-mono px-1.5 -ml-1 !outline-none w-full"
              value={client.bgLight}
              oninput={(e) => change({ bgLight: e.target.value })}
            ></textarea>
          </div>
        </div>

        <div
          class="flex items-start gap-3 textarea textarea-bordered p-3 pb-2 bg-black"
          data-theme="dark"
        >
          <div
            class="w-20 h-20 rounded bg-white shadow"
            style={client.bgDark}
          ></div>

          <div class="grow">
            <p class="text-xs opacity-75 mb-1.5">dark background (css)</p>
            <textarea
              class="bg-transparent font-mono px-1.5 -ml-1 !outline-none w-full"
              value={client.bgDark}
              oninput={(e) => change({ bgDark: e.target.value })}
            ></textarea>
          </div>
        </div>
      </div>
    {/if}

    <div class="flex flex-col gap-3">
      <PasswordInput
        label="secret"
        value={client.secret}
        onChange={(e) => change({ secret: e.target.value })}
      />

      <div class="input input-bordered rounded-md h-auto pl-4 pr-1.5 py-3">
        <div class="flex items-start mb-3 gap-1.5">
          <span class="label-text-alt opacity-70 w-[60px]">redirect uris</span>

          <div class="w-full">
            <textarea
              class="w-full bg-transparent text-sm focus:outline-none leading-snug"
              value={client.redirectUris}
              oninput={(e) => change({ redirectUris: e.target.value })}
              placeholder="..."
            ></textarea>
          </div>
        </div>

        {#if !client.redirectUris}
          <label class="flex items-center gap-3">
            <input
              type="checkbox"
              class="toggle toggle-xs !toggle-warning !bg-neutral"
              checked={client.autofillRedirectUri}
              onclick={(e) => change({ autofillRedirectUri: e.target.checked })}
            />

            <span class="text-xs opacity-75"
              >auto-populate with the first successful redirect uri</span
            >
          </label>
        {:else}
          <label class="flex items-center gap-3">
            <input
              type="checkbox"
              class="toggle toggle-xs !toggle-warning !bg-neutral"
              checked={client.fuzzyRedirectUri}
              onclick={(e) => change({ fuzzyRedirectUri: e.target.checked })}
            />

            <span class="text-xs opacity-75">allow wildcards</span>
          </label>
        {/if}
      </div>

      <ChecksEditor {client} {change} allowed={settings.checks} />
      <ScopesEditor {client} {change} {settings} />
    </div>
  </Page>
{/key}
