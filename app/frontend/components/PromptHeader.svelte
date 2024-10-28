<script>
  export let heading;
  export let client;
  export let redirectUri;
  export let prefix = "to";
  export let suffix = "";
</script>

<div class="flex items-center mb-6 gap-3">
  <div class="flex flex-col grow">
    <h2 class="text-black dark:text-white text-2xl md:text-3xl font-bold mb-1">
      {heading}
    </h2>

    <h1 class="text-xl md:text-2xl">
      {prefix} <span class="underline decoration-dotted">{client.name}</span>
      {suffix}
    </h1>
  </div>

  {#if client.logo}
    <div class="w-[65px] h-[65px] rounded-lg overflow-hidden">
      <img src={client.logo} alt={client.name} class="object-cover" />
    </div>
  {/if}
</div>
