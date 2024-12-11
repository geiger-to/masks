<script>
  import PromptLoading from "./PromptLoading.svelte";
  import { onMount } from "svelte";
  import { redirectTimeout } from "../util";

  let { auth, loading = $bindable() } = $props();

  onMount(() => {
    redirectTimeout(() => {
      window.location.assign(auth.redirectUri);
    }, 500);
  });
</script>

<PromptLoading />
