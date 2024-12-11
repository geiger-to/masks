<script>
  import { run } from "svelte/legacy";

  import _ from "lodash-es";
  import Time from "@/components/Time.svelte";
  import { ImageUp, Save, ChevronRight, X } from "lucide-svelte";
  import PasswordInput from "@/components/PasswordInput.svelte";
  import EditableImage from "@/components/EditableImage.svelte";
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

<a href={`/manage/client/${client.id}`}>
  <div class="bg-base-200 rounded-lg p-3 px-3 text-base-content">
    <div class="flex items-center gap-3">
      <EditableImage
        disabled
        endpoint="/upload/client"
        params={{ client_id: client.id }}
        src={client.logo}
        class="w-12 h-12"
      />

      <div class="flex-grow">
        <div class="font-bold">
          {client.name}
        </div>
        <div class="font-mono text-sm flex items-center gap-1.5">
          <span class="opacity-75">id</span>
          {client.id}
        </div>
      </div>
    </div>
  </div>
</a>
