<script>
  import _ from "lodash-es";
  import {
    LogOut,
    MailMinus,
    MailCheck,
    MailX,
    Check,
    AlertTriangle,
    RotateCcw,
    MailPlus,
    Trash2 as Trash,
    User,
  } from "lucide-svelte";
  import Page from "./Page.svelte";
  import Alert from "@/components/Alert.svelte";
  import Dropdown from "@/components/Dropdown.svelte";
  import Time from "@/components/Time.svelte";
  import Avatar from "@/components/Avatar.svelte";
  import Identicon from "@/components/Identicon.svelte";
  import EditableImage from "@/components/EditableImage.svelte";
  import Mutation from "@/components/Mutation.svelte";
  import {
    mutationStore,
    queryStore,
    gql,
    getContextClient,
  } from "@urql/svelte";
  import { LogoutMutation } from "@/util.js";

  let props = $props();
  let graphql = getContextClient();
  let actor = $state(props.actor);
  let emails = $state(props.actor?.loginEmails || []);
  let saving = $state(false);
  let loading = $state(true);
  let errors = $state();

  let save = (updates) => {
    updates = updates;
    saving = true;

    let update = mutationStore({
      client: graphql,
      query: gql`
        mutation ($input: EmailInput!) {
          email(input: $input) {
            emails {
              address
              verifiedAt
            }

            errors
          }
        }
      `,
      variables: { input: { ...updates, actorId: actor.id } },
    });

    update.subscribe((r) => {
      errors = r?.data?.email?.errors;
      errors = errors?.length ? errors : null;
      saving = r?.fetching;

      if (!saving && !errors) {
        loading = false;
        emails = r.data.email.emails;
      }
    });
  };

  let saveValues = (values) => {
    return () => {
      save(values);
    };
  };

  let address = $state("");

  let addEmail = () => {
    save({ address, action: "create" });
  };

  let verifyEmail = (address) => {
    return () => {
      save({ address, action: "verify" });
    };
  };

  let unverifyEmail = (address) => {
    return () => {
      save({ address, action: "unverify" });
    };
  };

  let deleteEmail = (address) => {
    return () => {
      if (confirm("Delete this email address?")) {
        save({ address, action: "delete" });
      }
    };
  };
</script>

<Mutation key="logout" query={LogoutMutation} input={{ actor: actor.id }}>
  {#snippet children({ mutate, mutating })}
    <Alert type="warn">
      <div class="flex items-center gap-3">
        <div class="grow flex flex-col gap-0.5">
          <span class="grow"> Logout of all devices... </span>
        </div>

        <button type="button" class="btn btn-sm" onclick={mutate}>
          logout
        </button>
      </div>
    </Alert>
  {/snippet}
</Mutation>
