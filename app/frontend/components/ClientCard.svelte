<script>
  import { run } from "svelte/legacy";

  import _ from "lodash-es";
  import Time from "svelte-time";
  import { ImageUp, Save, ChevronRight, X } from "lucide-svelte";
  import PasswordInput from "./PasswordInput.svelte";
  import EditableImage from "./EditableImage.svelte";
  import { getContext } from "svelte";
  import { mutationStore, gql, getContextClient } from "@urql/svelte";

  let result = $state();
  let errors;
  let page = getContext("page");
  let loading;

  /**
   * @typedef {Object} Props
   * @property {any} client
   * @property {boolean} [editing]
   * @property {any} [isEditing]
   */

  /** @type {Props} */
  let {
    client = $bindable(),
    editing = false,
    isEditing = () => {},
  } = $props();

  const updateClient = (input) => {
    result = mutationStore({
      client: page.graphql,
      query: gql`
        mutation ($input: ClientInput!) {
          client(input: $input) {
            client {
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

            errors
          }
        }
      `,
      variables: { input: { ...input, id: client.id } },
    });
  };

  const save = (input) => {
    return () => {
      loading = true;

      updateClient(
        _.pick(input, ["type", "redirectUris", "scopes", "redirectUris"])
      );
    };
  };

  const handleResult = (result) => {
    if (!result) {
      return;
    }

    loading = true;
    errors = null;

    if (!result?.data?.client) {
      return;
    }

    client = result?.data?.client?.client;
    errors = result?.data?.client?.errors;
    loading = false;
  };

  let updateName = _.debounce((value) => {
    if (value != client.name) {
      updateClient({ name: value });
    }
  }, 500);

  let form = $state({ ...client });
  let ICON_TYPES = {
    internal: "",
    public: "",
    confidential: "",
  };
  run(() => {
    handleResult($result);
  });
  run(() => {
    updateName(form.name);
  });
</script>

<div
  class="my-3 dark:bg-base-300 bg-base-200 rounded-lg p-3 px-3 text-base-content"
>
  <div class="flex items-center gap-3">
    <EditableImage
      disabled={!editing}
      endpoint="/upload/logo"
      params={{ client_id: client.id }}
      src={client?.logo}
      name={client?.name}
      class="w-12 h-12"
    />

    <div class="flex-grow">
      <input
        type="text"
        class="bg-transparent font-bold px-1.5 w-full rounded-sm"
        placeholder="required"
        bind:value={form.name}
        disabled={!editing}
      />

      <div class="flex items-baseline gap-3 pl-1.5">
        <span class="text-sm font-mono">{client.id}</span>
        <span class="text-xs italic"
          >last updated <Time relative timestamp={client.updatedAt} /></span
        >
      </div>
    </div>

    <div class="group join">
      {#if editing}
        <button class="btn join-item btn-primary" onclick={save(form)}
          ><Save size="15" /> save</button
        >
      {:else}
        <button class="btn btn-ghost" onclick={() => isEditing({ client })}
          ><ChevronRight /></button
        >
      {/if}
    </div>
  </div>

  {#if editing}
    <div class="divider my-1.5"></div>

    <div class="flex flex-col gap-1.5 mb-3">
      <div
        class="input input-bordered rounded-md pl-4 pr-1.5 py-1.5 flex items-center gap-3"
      >
        <span class="label-text opacity-70 w-[60px]">type</span>
        <select class="select select-sm w-full ml-1.5" bind:value={form.type}>
          <option selected={form.type == "internal"}>internal</option>
          <option selected={form.type == "confidential"}>confidential</option>
          <option selected={form.type == "public"}>public</option>
        </select>
      </div>

      <PasswordInput label="secret" bind:value={form.secret} />

      <div
        class="input input-bordered rounded-md h-auto pl-4 pr-1.5 py-1.5 flex items-baseline gap-3"
      >
        <span class="label-text opacity-70 w-[60px]">redirect uris</span>
        <textarea class="w-full textarea" bind:value={form.redirectUris}
        ></textarea>
      </div>

      <div
        class="input input-bordered h-auto rounded-md pl-4 pr-1.5 py-1.5 flex items-baseline gap-3"
      >
        <span class="label-text opacity-70 w-[60px]">scopes</span>
        <textarea class="w-full textarea" bind:value={form.scopes}></textarea>
      </div>
    </div>
  {/if}
</div>
