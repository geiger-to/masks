<script>
  export let icons;
</script>

<div
  class="w-4 h-4 rounded shadow overflow-hidden flex text-center items-center bg-white p-[1px]"
>
  <img src={icons?.dark} class="hidden dark:block w-full h-full" />
  <img src={icons?.light} class="dark:hidden w-full h-full" />
</div>
