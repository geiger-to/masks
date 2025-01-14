<script>
  import { CircleHelp as Icon } from "lucide-svelte";
  import Alert from "@/components/Alert.svelte";
  import PromptHeader from "./PromptHeader.svelte";
</script>

<PromptHeader heading="Login failed" class="mb-3" />

<p class="text-xl mb-12">
  A <code>client</code> must be supplied in the request.
</p>

<div class="flex items-center gap-6">
  <button onclick={() => history.back()} class="btn btn-error btn-lg text-lg">
    go back
  </button>
</div>
