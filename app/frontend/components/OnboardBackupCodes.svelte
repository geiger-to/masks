<script>
  import _ from "lodash-es";

  import { Binary, QrCode, Phone, Fingerprint } from "lucide-svelte";

  export let auth;
</script>

<div class="bg-base-100 rounded-lg p-3">
  <div class="flex items-center gap-3 pl-1.5">
    <Binary size="30" />
    <div class="grow">
      <div class="font-bold">Backup codes</div>
      <p class="text-xs">If you lose access to other credentials.</p>
    </div>
    <button class="btn"> save </button>
  </div>
</div>
