<script>
  export let heading;
  export let client;
  export let redirectUri;
  export let prefix = "to ";
  export let suffix = "";
</script>

<div class={`flex items-center gap-3 ${$$props.class}`}>
  <div class="flex flex-col grow">
    <h2
      class="text-black dark:text-white text-2xl md:text-3xl font-bold md:mb-1"
    >
      {heading}
    </h2>

    <h1 class="text-xl md:text-2xl">
      <slot name="subheading">
        {#if client}
          {prefix}<span class="underline decoration-dotted">{client.name}</span
          >{suffix}
        {/if}
      </slot>
    </h1>
  </div>

  <slot name="logo">
    {#if client?.logo}
      <div
        class="w-[45px] h-[45px] md:w-[65px] md:h-[65px] rounded-lg overflow-hidden"
      >
        <img src={client.logo} alt={client.name} class="object-cover" />
      </div>
    {/if}
  </slot>
</div>
