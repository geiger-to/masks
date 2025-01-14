<script>
  import { preventDefault, stopPropagation } from "svelte/legacy";

  import _ from "lodash-es";

  import PromptHeader from "./PromptHeader.svelte";
  import Verification from "../factors/Verification.svelte";

  let { ...props } = $props();
</script>

<div class="rows-1.5">
  <div>
    <Verification {...props} allow={{ second: true, backupCodes: true }}>
      {#snippet label(prompt)}
        to {prompt.auth.client.name}
      {/snippet}
    </Verification>
  </div>
</div>
