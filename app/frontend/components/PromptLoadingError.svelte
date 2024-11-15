<script>
  import { XCircle } from "lucide-svelte";
  import PromptHeader from "./PromptHeader.svelte";

  export let loadingError;
</script>

<PromptHeader heading="An error occurred..." class="mb-6">
  <div slot="logo">
    <XCircle size="50" class="text-error" />
  </div>

  <p slot="subheading">
    Your issue has been reported. It may be fixed by refreshing the page.
  </p>
</PromptHeader>

<div class="font-bold uppercase mb-3 text-xs">error message</div>
<code class="block w-full bg-black p-3 rounded-lg mb-6 text-green-300">
  {loadingError}
</code>

<button
  class="btn btn-lg"
  on:click|preventDefault|stopPropagation={() => window.location.reload()}
>
  refresh the page
</button>
