<script>
  import { Phone, MessageSquare, Mail, Upload, ImageUp } from "lucide-svelte";
  import PasswordInput from "@/components/PasswordInput.svelte";
  import Alert from "@/components/Alert.svelte";

  let { change, settings } = $props();
</script>

<div class="flex flex-col gap-3">
  <div class="flex flex-col gap-3 pr-1.5">
    <div class="flex items-center gap-2 mt-2">
      <p class="label-text-alt opacity-75 truncate">Sentry</p>
    </div>

    <label class="input input-sm input-bordered flex items-center gap-3">
      <span class="label-text-alt truncate opacity-70 w-[70px]">DSN</span>
      <input
        type="text"
        class="grow ml-3"
        placeholder="e.g. https://public@sentry.example.com/1..."
        value={settings.integration?.sentry?.dsn}
        oninput={(e) =>
          change({ integration: { sentry: { dsn: e.target.value } } })}
      />
    </label>
  </div>
</div>
