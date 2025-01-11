<script>
  import Icon from "@iconify/svelte";
  import { iconifyProvider } from "@/util.js";

  let { provider, ...props } = $props();
</script>

<Icon icon={iconifyProvider(provider)} />
