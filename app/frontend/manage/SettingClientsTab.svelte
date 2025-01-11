<script>
  import { Info } from "lucide-svelte";
  import Alert from "@/components/Alert.svelte";
  import CopyText from "@/components/CopyText.svelte";
  import PasswordInput from "@/components/PasswordInput.svelte";
  import Query from "@/components/Query.svelte";
  import Mutation from "@/components/Mutation.svelte";
  import ChecksEditor from "./ChecksEditor.svelte";
  import ProvidersEditor from "./ProvidersEditor.svelte";
  import { gql } from "@urql/svelte";

  let { settings, change, loading, errors, ...props } = $props();

  let query = gql`
    query {
      providers {
        nodes {
          id
          name
          type
          createdAt
        }
      }
    }
  `;

  let mutate = gql`
    mutation ($input: ProviderInput!) {
      provider(input: $input) {
        provider {
          id
        }

        errors
      }
    }
  `;

  let providerTypes = {
    github: {
      name: "Github",
      type: "github",
    },
  };

  let input = $state({});
</script>

<div class="flex flex-col gap-1.5">
  <Alert type="info" icon={Info} class="mb-1.5">
    Changes made below only apply to new clients...
  </Alert>

  <div class="bg-base-200 rounded-lg px-4 pt-2 pb-1.5 flex flex-col gap-0 mb-3">
    <label class="label cursor-pointer">
      <span class="label-text-alt"> Allow password login </span>
      <input
        type="checkbox"
        class="toggle toggle-xs"
        checked={settings.clients.allowPasswords}
        onclick={(e) =>
          change({ clients: { allowPasswords: e.target.checked } })}
      />
    </label>
    <label class="label cursor-pointer">
      <span class="label-text-alt"> Allow login links </span>
      <input
        type="checkbox"
        class="toggle toggle-xs"
        checked={settings.clients.allowLoginLinks}
        onclick={(e) =>
          change({ clients: { allowLoginLinks: e.target.checked } })}
      />
    </label>
  </div>

  <ChecksEditor
    change={(clients) => change({ clients })}
    allowed={settings.checks}
    client={settings.clients}
  />
</div>
