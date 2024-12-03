<script>
  /**
   * @typedef {Object} Props
   * @property {string} [type]
   * @property {any} [icon]
   * @property {import('svelte').Snippet} [children]
   */

  /** @type {Props} */
  let { type = "info", icon = null, children, class: cls } = $props();

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
    error: [
      `dark:bg-red-950 dark:border-red-900 dark:text-red-200`,
      `bg-red-50 border-red-100 text-red-800`,
    ],
    primary: [
      `dark:bg-indigo-950 dark:border-indigo-900 dark:text-indigo-200`,
      `bg-indigo-50 border-indigo-100 text-indigo-800`,
    ],
  };
</script>

<div
  class={[
    "px-3 py-3 border rounded-lg",
    "shadow flex items-start gap-3 text-left md:text-base text-sm",
    cls,
    ...(classes[type] || []),
  ].join(" ")}
>
  <p class="md:mx-1 mx-0.5 mb-0.5 md:mb-1 grow w-full">
    {@render children?.()}
  </p>

  {#if icon}
    {@const SvelteComponent = icon}
    <div>
      <SvelteComponent />
    </div>
  {/if}
</div>
