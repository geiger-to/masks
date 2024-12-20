<script>
  import _ from "lodash-es";
  import {
    LogOut,
    RotateCcw,
    MailPlus,
    Trash2 as Trash,
    User,
  } from "lucide-svelte";
  import Page from "./Page.svelte";
  import Alert from "@/components/Alert.svelte";
  import Time from "@/components/Time.svelte";
  import Identicon from "@/components/Identicon.svelte";
  import DeviceIcon from "@/components/DeviceIcon.svelte";
  import {
    mutationStore,
    queryStore,
    gql,
    getContextClient,
  } from "@urql/svelte";

  let { params, ...props } = $props();
  let graphql = getContextClient();
  let deviceFragment = gql`
    fragment DeviceFragment on Device {
      id
      name
      type
      ip
      os
      userAgent
      createdAt
    }
  `;

  let query = $derived(
    queryStore({
      client: getContextClient(),
      query: gql`
        query ($id: ID!) {
          device(id: $id) {
            ...DeviceFragment
          }
        }

        ${deviceFragment}
      `,
      variables: { id: params[0] },
      requestPolicy: "network-only",
    })
  );

  let result = $state({ data: {} });
  let device = $state();
  let saving = $state(false);
  let changes = $state({});
  let errors = $state();
  let original = $state(false);
  let loading = $state(true);
  let notFound = $state(false);

  let subscribe = () => {
    query.subscribe((r) => {
      result = r;
      device = r?.data?.device;
      original = original || device;
      loading = r.fetching;

      if (r.data && r.data.device === null) {
        notFound = true;
        loading = false;
      }

      if (device) {
        query.pause();
      }
    });
  };

  subscribe();

  let save = (updates) => {
    updates = updates || changes;
    saving = true;

    let update = mutationStore({
      client: graphql,
      query: gql`
        mutation ($input: DeviceInput!) {
          device(input: $input) {
            device {
              ...DeviceFragment
            }

            errors
          }
        }

        ${deviceFragment}
      `,
      variables: { input: { ...updates, id: device.id } },
    });

    update.subscribe((r) => {
      errors = r?.data?.device?.errors;
      errors = errors?.length ? errors : null;
      saving = r?.fetching;

      if (!saving && !errors) {
        changes = {};
        original = device = r?.data?.device?.device;
        loading = false;
      }
    });
  };

  let saveValues = (values) => {
    return () => {
      save(values);
    };
  };

  let change = (obj) => {
    changes = { ...changes, ...obj };
    device = { ...device, ...changes };
  };

  let isChanged = () => {
    return !_.isEqual(original, device);
  };

  let reset = () => {
    errors = null;
    device = original;
    changes = {};
  };

  let newEmail = $state("");

  let resetEmail = () => {
    newEmail = "";

    change({ createEmail: null });
  };

  let addEmail = () => {
    change({ createEmail: newEmail });
  };
</script>

<Page {...props} loading={!device} {notFound}>
  <div class={"mb-1.5 bg-base-100 rounded-lg p-3 py-1.5"}>
    <div class="flex items-center gap-3 w-full">
      <div class="px-1.5">
        <DeviceIcon {device} size="28" />
      </div>

      <div class="grow max-w-full overflow-hidden flex flex-col gap-0.5 mb-1">
        <div class="flex items-baseline gap-1.5">
          <span class="whitespace-nowrap font-bold" alt={device.userAgent}
            >{device.name} on {device.os}</span
          >
          <span class="opacity-75 text-xs">@</span>
          <span class="text-sm font-mono grow">{device.ip}</span>
        </div>
        <span class="whitespace-nowrap text-xs opacity-75"
          ><Time relative timestamp={device.createdAt} ago="old" /></span
        >
      </div>

      <button class="btn btn-sm"><LogOut size="16" /></button>
      <button class="btn btn-sm"><Trash size="16" /></button>
    </div>
  </div>

  <label class="input input-bordered flex items-center gap-3">
    <span class="label-text-alt opacity-75">ID</span>

    <input disabled type="text" class="grow" value={device.id} />
  </label>
</Page>
