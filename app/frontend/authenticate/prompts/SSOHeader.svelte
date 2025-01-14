<script>
  import Icon from "@iconify/svelte";
  import Alert from "@/components/Alert.svelte";
  import PromptIdentifier from "./PromptIdentifier.svelte";
  import { iconifyProvider } from "@/util.js";

  let { auth, heading, provider, ...props } = $props();
</script>

<div class="justify-center flex">
  <div
    class="bg-base-100 rounded-full shadow-inner mb-3 dark:fill-white fill-black w-full mx-10 max-w-[250px]"
  >
    <Icon
      icon={iconifyProvider(provider)}
      width="100%"
      height="100%"
      class="p-[10%] border-box"
    />
  </div>
</div>

<div class="flex items-center gap-6 justify-center py-6">
  <div class="text-2xl">
    {@render heading()}
  </div>
</div>

{@render props.alert?.()}

{#if auth?.actor}
  <div class="my-3 px-6">
    <PromptIdentifier {auth} />
  </div>
{/if}
