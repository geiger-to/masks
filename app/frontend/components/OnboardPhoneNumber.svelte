<script>
  import _ from "lodash-es";

  import { MessageSquare, Binary, QrCode, Phone, Fingerprint } from "lucide-svelte";

  export let auth;
</script>

<div class="bg-base-100 rounded-lg p-3">
  <div class="flex items-center gap-3 pl-1.5">
    <MessageSquare size="18" />

    <div class="grow">
      <div class="text-xs">SMS code</div>
    </div>

    <button class="btn btn-xs"> add a phone</button>
  </div>

  <div class="divider my-0 mb-1.0 opacity-75" />
</div>
