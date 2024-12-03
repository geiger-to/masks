<script>
  import { Info } from "lucide-svelte";
  import Alert from "@/components/Alert.svelte";
  import ChecksEditor from "./ChecksEditor.svelte";

  let { settings, change, loading, errors, ...props } = $props();
</script>

<Alert type="info" icon={Info}>
  Changes made here only apply to new clients...
</Alert>

<ChecksEditor
  change={(clients) => change({ clients })}
  allowed={settings.checks}
  client={settings.clients}
/>

<div class="bg-base-200 rounded-lg px-4 pt-2 pb-3 flex flex-col gap-0">
  <label class="label cursor-pointer">
    <span class="label-text-alt"> allow password login </span>
    <input
      type="checkbox"
      class="toggle toggle-xs"
      checked={settings.clients.allowPasswords}
      onclick={(e) => change({ clients: { allowPasswords: e.target.checked } })}
    />
  </label>
  <label class="label cursor-pointer">
    <span class="label-text-alt"> allow login links </span>
    <input
      type="checkbox"
      class="toggle toggle-xs"
      checked={settings.clients.allowLoginLinks}
      onclick={(e) =>
        change({ clients: { allowLoginLinks: e.target.checked } })}
    />
  </label>
</div>
