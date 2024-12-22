<script>
  import { Phone, MessageSquare, Mail, Upload, ImageUp } from "lucide-svelte";
  import PasswordInput from "@/components/PasswordInput.svelte";
  import Alert from "@/components/Alert.svelte";
  import DiskStorage from "./storage/DiskStorage.svelte";
  import S3Storage from "./storage/S3Storage.svelte";
  let { change, settings } = $props();

  let services = {
    disk: { name: "Filesystem", component: DiskStorage },
    s3: { name: "AWS / S3", component: S3Storage },
  };
</script>

<div class="flex flex-col gap-1">
  <div class="flex items-center gap-2">
    <p class="label-text-alt opacity-75 truncate grow">
      Store avatars, logos, and other uploads in...
    </p>
    <select
      class="select select-sm select-ghost"
      onchange={(e) => change({ integration: { storage: e.target.value } })}
    >
      {#each Object.entries(services) as [key, service]}
        <option selected={settings.integration.storage == key} value={key}
          >{service.name}</option
        >
      {/each}
    </select>
  </div>

  {#if services[settings.integration.storage]?.component}
    {@const StorageService = services[settings.integration.storage].component}
    <StorageService {change} {settings} />
  {/if}
</div>
