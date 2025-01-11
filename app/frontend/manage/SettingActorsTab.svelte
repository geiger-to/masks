<script>
  import Alert from "@/components/Alert.svelte";
  import { UserX, Trash, CalendarX2 } from "lucide-svelte";
  import ProvidersEditor from "./ProvidersEditor.svelte";

  let { settings, change, loading, errors, save, ...props } = $props();
</script>

<div class="flex flex-col gap-1.5">
  <div class="mb-1.5 pl-1.5">
    <p class="label-text-alt text-neutral-content opacity-75">Identification</p>
  </div>

  <div class="bg-base-200 rounded-lg px-4 py-1.5 mb-3">
    <label class="label cursor-pointer px-0">
      <div class="flex flex-col gap-1">
        <span class="label-text"> Nickname </span>
      </div>
      <input
        type="checkbox"
        class="toggle toggle-xs"
        checked={settings.nicknames.enabled}
        onclick={(e) => change({ nicknames: { enabled: e.target.checked } })}
      />
    </label>

    <label class="label cursor-pointer px-0">
      <div class="flex flex-col gap-1">
        <span class="label-text"> Email address </span>
      </div>
      <input
        type="checkbox"
        class="toggle toggle-xs"
        checked={settings.emails.enabled}
        onclick={(e) => change({ emails: { enabled: e.target.checked } })}
      />
    </label>
  </div>

  <div class="mb-3">
    <ProvidersEditor {settings} />
  </div>

  <div class="mb-1.5 pl-1.5">
    <p class="label-text-alt text-neutral-content opacity-75">Credentials</p>
  </div>

  <div class="bg-base-200 rounded-lg px-4 py-3 mb-3">
    <div class="flex items-center gap-3 text-xs mb-1.5">
      <span class="text-sm grow">Passwords</span>
      <span class="text-xs truncate opacity-75">characters</span>
      <label class="flex items-center gap-3">
        <input
          type="text"
          placeholder="..."
          class="input input-xs max-w-[60px]"
          value={settings.passwords.minChars}
          oninput={(e) => change({ passwords: { minChars: e.target.value } })}
        />
        <span class="opacity-75">min</span>
      </label>
      <label class="flex items-center gap-3">
        <input
          type="text"
          placeholder="..."
          class="input input-xs max-w-[60px]"
          value={settings.passwords.maxChars}
          oninput={(e) => change({ passwords: { maxChars: e.target.value } })}
        />

        <span class="opacity-75">max</span>
      </label>
    </div>

    <label class="label cursor-pointer pl-0">
      <div class="flex flex-col gap-1">
        <span class="label-text"> Passkeys </span>
      </div>
      <input
        type="checkbox"
        class="toggle toggle-xs"
        disabled
        checked={settings.passkeys.enabled}
        onclick={(e) => change({ passkeys: { enabled: e.target.checked } })}
      />
    </label>

    <label class="label cursor-pointer pl-0">
      <div class="flex flex-col gap-1">
        <span class="label-text"> Login links </span>
      </div>
      <input
        type="checkbox"
        class="toggle toggle-xs"
        checked={settings.loginLinks.enabled}
        onclick={(e) => change({ loginLinks: { enabled: e.target.checked } })}
      />
    </label>

    <label class="label cursor-pointer pl-0">
      <div class="flex flex-col gap-1">
        <span class="label-text"> Phone-based verification</span>
      </div>
      <input
        type="checkbox"
        class="toggle toggle-xs"
        checked={settings.phones.enabled}
        onclick={(e) => change({ phones: { enabled: e.target.checked } })}
      />
    </label>

    <label class="label cursor-pointer pl-0">
      <div class="flex flex-col gap-1">
        <span class="label-text">
          Hardware keys <i>(Webauthn)</i>
        </span>
      </div>
      <input
        type="checkbox"
        class="toggle toggle-xs"
        checked={settings.webauthn.enabled}
        onclick={(e) => change({ webauthn: { enabled: e.target.checked } })}
      />
    </label>

    <label class="label cursor-pointer pl-0">
      <div class="flex flex-col gap-1">
        <span class="label-text"> One-time passwords (<i>TOTP</i>)</span>
      </div>
      <input
        type="checkbox"
        class="toggle toggle-xs"
        checked={settings.totpCodes.enabled}
        onclick={(e) => change({ totpCodes: { enabled: e.target.checked } })}
      />
    </label>

    <span class="block text-sm truncate mt-1.5 mb-3">Backup codes</span>

    <div class="flex items-center gap-3 text-xs mb-3">
      <label class="flex items-center gap-3">
        <span class="text-xs truncate opacity-75">characters</span>
        <input
          type="text"
          placeholder="..."
          class="input input-xs max-w-[60px]"
          value={settings.backupCodes.minChars}
          oninput={(e) => change({ backupCodes: { minChars: e.target.value } })}
        />
        <span class="opacity-75">min</span>
      </label>
      <label class="flex items-center gap-3">
        <input
          type="text"
          placeholder="..."
          class="input input-xs max-w-[60px]"
          value={settings.backupCodes.maxChars}
          oninput={(e) => change({ backupCodes: { maxChars: e.target.value } })}
        />
        <span class="opacity-75">max</span>
      </label>
    </div>
    <div class="flex items-center gap-3 text-xs">
      <span class="text-xs opacity-75">require</span>
      <label class="flex items-center gap-3">
        <input
          type="text"
          placeholder="..."
          class="input input-xs max-w-[60px]"
          value={settings.backupCodes.total}
          oninput={(e) => change({ backupCodes: { total: e.target.value } })}
        />

        <span class="opacity-75">when generating a new set</span>
      </label>
    </div>
  </div>
</div>
