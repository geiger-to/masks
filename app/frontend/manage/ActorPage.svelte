<script>
  import _ from "lodash-es";
  import { RotateCcw, MailPlus, Trash2 as Trash, User } from "lucide-svelte";
  import Page from "./Page.svelte";
  import Alert from "@/components/Alert.svelte";
  import Time from "@/components/Time.svelte";
  import Avatar from "@/components/Avatar.svelte";
  import Identicon from "@/components/Identicon.svelte";
  import EditableImage from "@/components/EditableImage.svelte";
  import ActorPhones from "./ActorPhones.svelte";
  import ActorEmails from "./ActorEmails.svelte";
  import ActorHardwareKeys from "./ActorHardwareKeys.svelte";
  import ActorBackupCodes from "./ActorBackupCodes.svelte";
  import ActorTotpSecrets from "./ActorTotpSecrets.svelte";
  import {
    mutationStore,
    queryStore,
    gql,
    getContextClient,
  } from "@urql/svelte";

  let { params, ...props } = $props();
  let graphql = getContextClient();
  let actorFragment = gql`
    fragment ActorFragment on Actor {
      id
      name
      nickname
      identifier
      identifierType
      identiconId
      loginEmail
      loginEmails {
        address
        verifiedAt
      }
      avatar
      avatarCreatedAt
      passwordChangedAt
      passwordChangeable
      savedBackupCodesAt
      remainingBackupCodes
      hardwareKeys {
        id
        name
        createdAt
        icons {
          light
          dark
        }
      }
      phones {
        number
        createdAt
        verifiedAt
      }
      otpSecrets {
        id
        name
        createdAt
      }
      createdAt
      updatedAt
    }
  `;

  let query = $derived(
    queryStore({
      client: getContextClient(),
      query: gql`
        query ($id: ID!) {
          actor(id: $id) {
            ...ActorFragment
          }
        }

        ${actorFragment}
      `,
      variables: { id: params[0] },
      requestPolicy: "network-only",
    })
  );

  let result = $state({ data: {} });
  let actor = $state();
  let saving = $state(false);
  let changes = $state({});
  let errors = $state();
  let original = $state(false);
  let loading = $state(true);
  let notFound = $state(false);

  let subscribe = () => {
    query.subscribe((r) => {
      result = r;
      actor = r?.data?.actor;
      original = original || actor;
      loading = r.fetching;

      if (r.data && r.data.actor === null) {
        notFound = true;
        loading = false;
      }

      if (actor) {
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
        mutation ($input: ActorInput!) {
          actor(input: $input) {
            actor {
              ...ActorFragment
            }

            errors
          }
        }

        ${actorFragment}
      `,
      variables: { input: { ...updates, id: actor.id } },
    });

    update.subscribe((r) => {
      errors = r?.data?.actor?.errors;
      errors = errors?.length ? errors : null;
      saving = r?.fetching;

      if (!saving && !errors) {
        changes = {};
        original = actor = r?.data?.actor?.actor;
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
    actor = { ...actor, ...changes };
  };

  let isChanged = () => {
    return !_.isEqual(original, actor);
  };

  let reset = () => {
    errors = null;
    actor = original;
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

<Page {...props} loading={!actor} {notFound}>
  <div class="flex flex-col gap-3">
    <div class="grow flex items-start gap-3 p-1.5 rounded-lg bg-base-100">
      <div class="w-12 h-12">
        <EditableImage
          endpoint="/upload/avatar"
          params={{ actor_id: actor.id }}
          src={actor?.avatar}
          class="w-12 h-12"
        />
      </div>

      <div class="grow flex flex-col truncate">
        <div class="font-bold text-xl dark:text-white text-black truncate">
          {original.name || original.identifier}
        </div>

        <div class="flex items-center gap-1.5">
          {#if props.actor.identifier == actor.identifier}
            <div class="text-xs italic font-bold text-info">you</div>
          {/if}

          <div class="text-xs">
            last login

            <span class="italic">
              {#if actor.lastLoginAt}
                <Time relative timestamp={actor.lastLoginAt} />
              {:else}
                never
              {/if}
            </span>
          </div>
        </div>
      </div>

      <div class="min-w-6 w-6 h-6 md:w-12 md:h-12 bg-black rounded">
        <Identicon id={actor.identiconId} />
      </div>
    </div>

    <Alert type="neutral" class="!py-1.5 pr-0.5 pl-3">
      <div class="flex items-center gap-3">
        <User size="16" />

        <div class="text-xs grow">
          <span class="opacity-75">saved</span>

          {#key actor.updatedAt}
            <Time timestamp={actor.updatedAt} />
          {/key}
        </div>

        <button
          class="btn btn-primary btn-sm"
          disabled={!isChanged()}
          onclick={(e) => save(changes)}
        >
          save
        </button>
      </div>
    </Alert>

    <label class="input input-bordered flex items-center gap-3">
      <span class="label-text-alt opacity-75">full name</span>

      <input
        type="text"
        class="grow"
        value={actor.name}
        placeholder="..."
        oninput={(e) => change({ name: e.target.value || null })}
      />
    </label>

    <label class="input input-bordered flex items-center gap-3">
      <span class="label-text-alt opacity-75">nickname</span>

      <input
        type="text"
        class="grow"
        value={actor.nickname}
        placeholder="..."
        oninput={(e) => change({ nickname: e.target.value || null })}
      />
    </label>

    <div class="flex flex-col">
      <span class="text-xs opacity-75 mb-1.5">emails</span>

      <ActorEmails {actor} />
    </div>

    <div class="flex flex-col">
      <span class="text-xs opacity-75 mb-1.5">phones</span>

      <ActorPhones {actor} />
    </div>

    <div class="flex flex-col">
      <span class="text-xs opacity-75 mb-1.5">hardware keys</span>

      <ActorHardwareKeys {actor} />
    </div>

    <div class="flex flex-col">
      <span class="text-xs opacity-75 mb-1.5">TOTP</span>

      <ActorTotpSecrets {actor} />
    </div>

    <div class="flex flex-col">
      <span class="text-xs opacity-75 mb-1.5">backup codes</span>

      <ActorBackupCodes {actor} />
    </div>
  </div>
</Page>
