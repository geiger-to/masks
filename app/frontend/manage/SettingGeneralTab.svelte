<script>
  import { MoveLeft, CornerLeftUp, Info } from "lucide-svelte";
  import Alert from "@/components/Alert.svelte";
  import ChecksEditor from "./ChecksEditor.svelte";
  import EditableImage from "@/components/EditableImage.svelte";

  let { settings, change, loading, errors, save, ...props } = $props();
</script>

<div class="flex flex-col gap-1.5">
  <div class="mb-3">
    <div class="grow flex flex-col gap-1.5 mb-3">
      <label
        class="input input-bordered input-sm text-lg flex items-center gap-3"
      >
        <span class="opacity-75 text-xs min-w-[35px]">name</span>
        <input
          type="text"
          class="grow font-bold pb-0.5"
          value={settings.theme.name}
          oninput={(e) => change({ theme: { name: e.target.value } })}
        />
      </label>
      <label class="input input-bordered input-sm flex items-center gap-3 grow">
        <span class="opacity-75 text-xs min-w-[35px]">url</span>
        <input
          type="text"
          class="grow placeholder:opacity-75"
          placeholder="your site's home page..."
          value={settings.theme.url}
          oninput={(e) => change({ theme: { url: e.target.value } })}
        />
      </label>
    </div>

    <div class="">
      <div class="flex items-end gap-3">
        <div class="flex flex-col items-center gap-3">
          <EditableImage
            endpoint="/upload/logo?theme=light"
            src={settings.lightLogoUrl}
            name={settings.theme.name}
            class="w-20 h-20 rounded-lg border border-neutral bg-base-200 p-0.5"
          />
          <span
            class="text-xs dark:bg-white bg-base-300 text-black opacity-75 p-0.5 px-1.5 rounded"
            >light logo</span
          >
        </div>
        <div class="flex flex-col items-center gap-3">
          <EditableImage
            endpoint="/upload/logo?theme=dark"
            src={settings.darkLogoUrl}
            name={settings.theme.name}
            class="w-20 h-20 rounded-lg border border-neutral bg-base-200 p-0.5"
          />
          <span
            class="text-xs bg-black text-white opacity-75 p-0.5 px-1.5 rounded"
            >dark logo</span
          >
        </div>
        <div class=" flex flex-col items-center gap-3">
          <EditableImage
            endpoint="/upload/favicon"
            src={settings.faviconUrl}
            name={settings.theme.name}
            class="w-12 h-12 rounded-lg border border-neutral bg-base-200 p-0.5"
          />

          <span
            class="text-xs bg-neutral text-neutral-content opacity-75 p-0.5 px-1.5 rounded"
            >favicon</span
          >
        </div>
      </div>
    </div>
  </div>

  <p class="label-text-alt opacity-75">lifetimes</p>

  <div class="grow flex flex-col gap-1.5 mb-3">
    <label class="input input-bordered input-sm flex items-center gap-3">
      <span class="opacity-75 text-xs min-w-[35px]">session</span>
      <input
        type="text"
        class="grow placeholder:opacity-75"
        value={settings.sessions.lifetime}
        placeholder="expires when the browser exits..."
        oninput={(e) => change({ sessions: { lifetime: e.target.value } })}
      />
    </label>
    <label class="input input-bordered input-sm flex items-center gap-3 grow">
      <span class="opacity-75 text-xs min-w-[35px]">device</span>
      <input
        type="text"
        class="grow placeholder:opacity-75"
        placeholder="expires when the browser exits..."
        value={settings.devices.lifetime}
        oninput={(e) => change({ devices: { lifetime: e.target.value } })}
      />
    </label>
  </div>

  <p class="label-text-alt opacity-75">environment</p>

  <div class="flex flex-col gap-1.5">
    <label class="input input-bordered input-sm flex items-center gap-3">
      <span class="opacity-75 text-xs">public url</span>
      <input type="text" class="grow" value={settings?.url} disabled />
    </label>

    <label class="input input-bordered input-sm flex items-center gap-3">
      <span class="opacity-75 text-xs">timezone</span>
      <input type="text" class="grow" value={settings?.timezone} disabled />
    </label>

    <label class="input input-bordered input-sm flex items-center gap-3">
      <span class="opacity-75 text-xs">region</span>
      <input type="text" class="grow" value={settings?.region} disabled />
    </label>
  </div>
</div>
