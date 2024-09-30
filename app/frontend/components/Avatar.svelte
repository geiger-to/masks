<script>
  import Identicon from "./Identicon.svelte";
  export let onClick;
  export let nickname;
</script>

<a
  href="#"
  on:click|preventDefault|stopPropagation={onClick}
  class="leading-none"
>
  <div class="avatar placeholder">
    <div class="bg-black text-neutral-content rounded-lg w-8 p-0.5">
      <Identicon {nickname} />
    </div>
  </div>
</a>
