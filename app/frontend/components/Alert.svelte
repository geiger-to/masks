<script>
  export let type = "info";
  export let icon = null;

  let classes = {
    info: [
      `dark:bg-sky-950 dark:border-sky-900 dark:text-sky-200`,
      `bg-sky-50 border-sky-200 text-sky-800`,
    ],
    neutral: [
      `dark:bg-gray-950 dark:border-gray-900 dark:text-gray-200`,
      `bg-gray-50 border-gray-200 text-gray-800`,
    ],
    success: [
      `dark:bg-green-950 dark:border-green-900 dark:text-green-200`,
      `bg-green-50 border-green-200 text-green-800`,
    ],
    warn: [
      `dark:bg-yellow-950 dark:border-yellow-900 dark:text-yellow-200`,
      `bg-yellow-50 border-yellow-100 text-yellow-800`,
    ],
  };
</script>

<div
  class={[
    "px-3 py-3 border rounded-lg",
    "shadow flex items-start gap-3 text-left mb-3 md:text-base text-sm",
    $$props.class,
    ...(classes[type] || []),
  ].join(" ")}
>
  <p class="md:ml-1 ml-0.5 grow">
    <slot />
  </p>

  {#if icon}
    <div>
      <svelte:component this={icon} />
    </div>
  {/if}
</div>
