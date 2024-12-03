<script>
  import Alert from "@/components/Alert.svelte";

  let { settings, change, loading, errors, save, ...props } = $props();
</script>

<div class="bg-base-200 rounded-lg px-4 py-3">
  <div class="mb-1.5">
    <p class="label-text-alt opacity-75">Identification</p>
  </div>
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
  <label class="label cursor-pointer px-0">
    <div class="flex flex-col gap-1">
      <span class="label-text"> Passkey </span>
    </div>
    <input
      type="checkbox"
      class="toggle toggle-xs"
      disabled
      checked={settings.passkeys.enabled}
      onclick={(e) => change({ passkeys: { enabled: e.target.checked } })}
    />
  </label>
</div>

<div class="bg-base-200 rounded-lg px-4 py-3">
  <div class="flex flex-col gap-1 mb-3">
    <span class="label-text-alt opacity-75">Credentials</span>
  </div>

  <div class="flex items-center gap-3 text-xs mb-1.5">
    <span class="text-sm">Passwords</span>
    <span class="text-xs truncate opacity-75">characters</span>
    <label class="flex items-center gap-3">
      <input
        type="text"
        placeholder="..."
        class="input input-xs max-w-[60px]"
        value={settings.passwords.min}
        oninput={(e) => change({ passwords: { min: e.target.value } })}
      />
      <span class="opacity-75">min</span>
    </label>
    <label class="flex items-center gap-3">
      <input
        type="text"
        placeholder="..."
        class="input input-xs max-w-[60px]"
        value={settings.passwords.max}
        oninput={(e) => change({ passwords: { max: e.target.value } })}
      />

      <span class="opacity-75">max</span>
    </label>
  </div>

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
      <span class="label-text"> TOTP verification </span>
    </div>
    <input
      type="checkbox"
      class="toggle toggle-xs"
      checked={settings.totpCodes.enabled}
      onclick={(e) => change({ totpCodes: { enabled: e.target.checked } })}
    />
  </label>

  <label class="label cursor-pointer pl-0">
    <div class="flex flex-col gap-1">
      <span class="label-text"> SMS verification </span>
    </div>
    <input
      type="checkbox"
      class="toggle toggle-xs"
      checked={settings.smsCodes.enabled}
      onclick={(e) => change({ smsCodes: { enabled: e.target.checked } })}
    />
  </label>
</div>

<div class="bg-base-200 rounded-lg px-4 py-3">
  <p class="label-text-alt opacity-75 mb-3">Backup codes</p>
  <div class="flex items-center gap-3 text-xs mb-3">
    <span class="text-sm truncate">characters</span>
    <label class="flex items-center gap-3">
      <input
        type="text"
        placeholder="..."
        class="input input-xs max-w-[60px]"
        value={settings.backupCodes.min}
        oninput={(e) => change({ backupCodes: { min: e.target.value } })}
      />
      <span class="opacity-75">min</span>
    </label>
    <label class="flex items-center gap-3">
      <input
        type="text"
        placeholder="..."
        class="input input-xs max-w-[60px]"
        value={settings.backupCodes.max}
        oninput={(e) => change({ backupCodes: { max: e.target.value } })}
      />
      <span class="opacity-75">max</span>
    </label>
  </div>
  <div class="flex items-center gap-3 text-xs">
    <span class="text-sm">require</span>
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
