<script>
  import CopyButton from "./CopyButton.svelte";

  let { ...props } = $props();
</script>

<label
  class="input input-xs border-none min-w-0 flex items-center gap-1.5 grow !bg-transparent w-full px-0 !outline-none"
>
  <CopyButton value={props.text} />

  <span class={`text-base-content opacity-75 ${props.labelClass}`}>
    {props.label}
  </span>

  <input
    type="text"
    value={props.text}
    disabled
    class="min-w-0 w-full text-base-content !outline-none"
  />
</label>
