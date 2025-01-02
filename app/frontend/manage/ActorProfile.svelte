<script>
  import ActorPassword from "./ActorPassword.svelte";
  import ActorEmails from "./ActorEmails.svelte";
  import ActorPhones from "./ActorPhones.svelte";

  let { actor, change } = $props();
</script>

<div class="flex flex-col gap-1.5 mb-1.5">
  <label class="input input-bordered flex items-center gap-3">
    <span class="label-text-alt opacity-75">full name</span>

    <input
      type="text"
      class="grow"
      value={actor.name}
      placeholder="..."
      oninput={(e) => change({ name: e.target.value || null })}
    />
  </label>

  <label class="input input-bordered flex items-center gap-3">
    <span class="label-text-alt opacity-75">nickname</span>

    <input
      type="text"
      class="grow"
      value={actor.nickname}
      placeholder="..."
      oninput={(e) => change({ nickname: e.target.value || null })}
    />
  </label>

  {#key actor.passwordChangedAt}
    <ActorPassword {actor} {change} />
  {/key}

  <span class="text-xs opacity-75 mt-3">emails</span>

  <ActorEmails {actor} />

  <span class="text-xs opacity-75 mt-3">phones</span>

  <ActorPhones {actor} />
</div>
