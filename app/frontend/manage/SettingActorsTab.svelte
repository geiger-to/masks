<script>
  import Alert from "@/components/Alert.svelte";
  import { UserX, Trash, CalendarX2 } from "lucide-svelte";

  let { settings, change, loading, errors, save, ...props } = $props();

  let deleteInactive = $state(settings.actors.lifetime);
</script>

<div class="flex flex-col gap-1.5">
  <Alert type="gray" class="mb-3 !py-1.5">
    <div class="flex items-center gap-0">
      <div
        class="bg-error rounded p-[3px] pl-[4px] text-error-content flex items-center justify-center m-1.5"
      >
        <UserX size="14" class="" />
      </div>

      <input
        type="checkbox"
        class="checkbox checkbox-sm ml-3"
        bind:checked={deleteInactive}
      />

      <span class="opacity-75 whitespace-nowrap text-sm pl-3"
        >Delete inactive actors after...</span
      >

      {#if deleteInactive}
        <label
          class="input dark:input-ghost input-sm min-w-0 flex items-center
          gap-0.5 grow ml-1 !pl-1.5 !outline-none"
        >
          <input
            type="text"
            class="!min-w-0 px-0 max-w-[90px] placeholder:opacity-50"
            value={settings.actors.lifetime}
            placeholder="e.g. 1 year"
            oninput={(e) => change({ actors: { lifetime: e.target.value } })}
          />

          <span class="opacity-75 w-full grow whitespace-nowrap"
            >of inactivity...</span
          >
        </label>
      {/if}
    </div>
  </Alert>
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

  <div class="mb-1.5 pl-1.5">
    <p class="label-text-alt text-neutral-content opacity-75">Credentials</p>
  </div>

  <div class="bg-base-200 rounded-lg px-4 py-3 mb-3">
    <div class="flex items-center gap-3 text-xs mb-1.5">
      <span class="text-sm">Passwords</span>
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
        <span class="label-text"> Phones</span>
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
        <span class="label-text"> TOTP verification </span>
      </div>
      <input
        type="checkbox"
        class="toggle toggle-xs"
        checked={settings.totpCodes.enabled}
        onclick={(e) => change({ totpCodes: { enabled: e.target.checked } })}
      />
    </label>
  </div>

  <div class="mb-1.5 pl-1.5">
    <p class="label-text-alt opacity-75 text-neutral-content">Backup codes</p>
  </div>

  <div class="bg-base-200 rounded-lg px-4 py-3 mb-3">
    <div class="flex items-center gap-3 text-xs mb-3">
      <span class="text-sm truncate">Characters</span>
      <label class="flex items-center gap-3">
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
</div>
