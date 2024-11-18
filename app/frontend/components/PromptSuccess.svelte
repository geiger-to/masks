<script>
  import { ShieldCheck as Check } from "lucide-svelte";
  import PromptHeader from "./PromptHeader.svelte";
  import PromptIdentifier from "./PromptIdentifier.svelte";
  import PasswordInput from "./PasswordInput.svelte";
  import PromptLoading from "./PromptLoading.svelte";
  import Identicon from "./Identicon.svelte";
  import { onMount } from "svelte";
  import { redirectTimeout } from "../util";

  let { auth } = $props();

  onMount(() => {
    redirectTimeout(() => {
      window.location.replace(auth.redirectUri);
    }, 2000);
  });
</script>

<div class="py-12 animate-fade-in-1s">
  <div class="mb-6">
    <div
      class="mx-auto text-center w-[100px] h-[100px] bg-black rounded-lg shadow-xl"
    >
      {#if auth?.actor?.avatar}
        <img src={auth.actor.avatar} class="object-cover" alt="avatar" />
      {:else}
        <Identicon id={auth.actor.identiconId} />
      {/if}
    </div>

    <div class="text-center pt-1.5 opacity-75 text-sm">
      {auth?.actor?.identifier}
    </div>
  </div>

  <div class="text-center">
    <div class="text-2xl leading-relaxed animate-pulse">
      Continuing to<br /><a href={auth.redirectUri} class="font-bold"
        >{auth?.client?.name}</a
      >
    </div>
  </div>

  <div class="text-center pt-6">
    <span
      class="loading loading-spinner loading-lg mx-auto loading-dots text-success"
    ></span>
  </div>
</div>
