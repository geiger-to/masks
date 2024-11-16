<script>
  import PromptLoading from "./PromptLoading.svelte";
  import { onMount } from "svelte";
  import { redirectTimeout } from "../util";

  export let auth;

  onMount(() => {
    redirectTimeout(() => {
      window.location.assign(auth.redirectUri);
    }, 500);
  });
</script>

<PromptLoading />
