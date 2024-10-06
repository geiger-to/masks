<script>
  import {
    Save,
    ChevronDown,
    X,
    Computer,
    Smartphone,
    Tablet,
    Gamepad,
    Tv,
    Tv2,
    HelpCircle,
    Car,
    Camera,
    Bluetooth,
  } from "lucide-svelte";
  import Time from "svelte-time";

  export let device;
  export let inline;

  let form = { ...device };
  let icon = {
    desktop: Computer,
    smartphone: Smartphone,
    "feature phone": Smartphone,
    tablet: Tablet,
    phablet: Tablet,
    "portable media player": Tablet,
    console: Gamepad,
    tv: Tv,
    "smart display": Tv2,
    "car browser": Car,
    camera: Camera,
    "smart speaker": Bluetooth,
    wearable: Bluetooth,
    peripheral: Bluetooth,
  };
</script>

<div class={inline ? "" : "my-1.5 bg-base-200 rounded-lg p-3 px-3"}>
  <div class="flex items-center gap-3 text-sm">
    <svelte:component this={icon[device.deviceType] || HelpCircle} size="15" />
    <span class="" alt={device.userAgent}
      ><i>{device.name}</i> on <i>{device.osName}</i></span
    >
    <span class="font-mono">{device.ipAddress}</span>
    <span class="italic"
      >created <Time relative timestamp={device.createdAt} /></span
    >
  </div>
</div>
