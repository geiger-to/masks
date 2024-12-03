<script>
  import { Phone, MessageSquare, Mail, Upload, ImageUp } from "lucide-svelte";
  import PasswordInput from "@/components/PasswordInput.svelte";
  import Alert from "@/components/Alert.svelte";
  let { change, settings } = $props();
</script>

<div class="flex flex-col gap-3">
  <div class="flex flex-col gap-3 pr-1.5">
    <div class="flex items-center gap-2 mt-2">
      <p class="label-text-alt opacity-75 truncate">
        Used for notifications and verification emails...
      </p>
    </div>

    <label class="input input-sm input-bordered flex items-center gap-3">
      <span class="label-text-alt truncate opacity-70 w-[70px]">address</span>
      <input
        type="text"
        class="grow ml-3"
        placeholder="e.g. smtp.example.com..."
        value={settings.integration.smtp.address}
        oninput={(e) =>
          change({ integration: { smtp: { address: e.target.value } } })}
      />
    </label>
    <label class="input input-sm input-bordered flex items-center gap-3">
      <span class="label-text-alt truncate opacity-70 w-[70px]">port</span>
      <input
        type="text"
        class="grow ml-3"
        placeholder="e.g. 25, 465 or 587..."
        value={settings.integration.smtp.port}
        oninput={(e) =>
          change({ integration: { smtp: { port: e.target.value } } })}
      />
    </label>
    <label class="input input-sm input-bordered flex items-center gap-3">
      <span class="label-text-alt truncate opacity-70 w-[70px]">username</span>
      <input
        type="text"
        class="grow ml-3"
        placeholder="..."
        value={settings.integration.smtp.username}
        oninput={(e) =>
          change({ integration: { smtp: { username: e.target.value } } })}
      />
    </label>
    <PasswordInput
      class="input-sm"
      label="password"
      placeholder="..."
      value={settings.integration.smtp.password}
      onChange={(e) =>
        change({ integration: { smtp: { password: e.target.value } } })}
    />
  </div>
</div>
