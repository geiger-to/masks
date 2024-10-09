<script>
  import { OctagonX } from "lucide-svelte";

  export let icon = OctagonX;
  export let text = "";
</script>

<div class={$$props.class}>
  <div
    class={[
      "flex items-center gap-3 rounded-lg text-left",
      "leading-snug dark:text-red-200 text-red-600",
    ].join(" ")}
  >
    <span
      class="text-red-50 bg-red-700 rounded-full flex w-10 h-10 items-center justify-center text-center"
    >
      <svelte:component this={icon} size="26" />
    </span>

    <div><slot>{text}</slot></div>
  </div>
</div>
