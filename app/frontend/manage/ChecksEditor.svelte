<script>
  import { Clock, Lock as Icon, X, Plus } from "lucide-svelte";

  let { disabled, client, change, allowed, ...props } = $props();

  let toggleCheck = (check) => {
    return () => {
      if (client.checks.includes(check)) {
        change({ checks: client.checks.filter((c) => c != check) });
      } else {
        change({ checks: [...client.checks, check] });
      }
    };
  };

  let lifetimes = {
    authorizationCodeExpiresIn: {
      name: "authorization codes",
    },
    accessTokenExpiresIn: {
      name: "access tokens",
    },
    refreshTokenExpiresIn: {
      name: "refresh tokens",
    },
    clientTokenExpiresIn: {
      name: "client tokens",
    },
    internalTokenExpiresIn: {
      name: "internal tokens",
    },
    idTokenExpiresIn: {
      name: "id tokens",
    },
    loginLinkExpiresIn: {
      name: "login link",
    },
    authAttemptExpiresIn: {
      name: "auth attempt",
    },
    emailVerificationExpiresIn: {
      name: "verified email",
    },
    loginLinkFactorExpiresIn: {
      name: "auth via login link",
    },
    ssoFactorExpiresIn: {
      name: "auth via single sign-on",
    },
    passwordFactorExpiresIn: {
      name: "auth via password",
    },
    secondFactorBackupCodeExpiresIn: {
      name: "2FA with backup code",
    },
    secondFactorPhoneExpiresIn: {
      name: "2FA with SMS",
    },
    secondFactorTotpCodeExpiresIn: {
      name: "2FA with TOTP",
    },
    secondFactorWebauthnExpiresIn: {
      name: "2FA with Webauthn",
    },
  };

  let labels = {
    "Masks::Checks::Device": {
      name: "Device",
      desc: "Require an approved, verified device",
    },
    "Masks::Checks::Credentials": {
      name: "Password",
      desc: "Check for a primary credential (like a password) to authenticate",
    },
    "Masks::Checks::SecondFactor": {
      name: "2FA",
      desc: "Require a secondary credential to authenticate",
    },
    "Masks::Checks::ClientConsent": {
      name: "Approval",
      desc: "Prompt actors to approve access and the scopes granted to this client",
    },
    "Masks::Checks::Onboarded": {
      name: "Onboarded",
      desc: "Show the onboarding flow (if not onboarded) before accessing this client",
    },
    "Masks::Checks::VerifiedEmail": {
      name: "Verified email",
      desc: "Actors must verify their email to access this client",
    },
  };

  let editing = $state(props.editing);
</script>

<div class="bg-base-200 py-3 px-4 rounded-lg">
  <div class="flex items-center gap-1.5 mb-3 opacity-75">
    <Icon size="12" />

    <div class="text-xs grow">{props.label || "checks"}</div>

    {#if !disabled && !props.editing}
      <button
        class="btn btn-xs btn-link text-base-content opacity-75 px-0"
        onclick={() => (editing = !editing)}
        >{editing ? "hide lifetimes" : "lifetimes..."}</button
      >
    {/if}
  </div>

  <div class="flex flex-wrap items-center gap-1.5 mb-1.5 gap-y-3">
    {#each allowed as check}
      {#if disabled}
        <p
          title={labels[check].desc}
          class={`badge ${client?.checks?.includes(check) ? "badge-info" : "badge-neutral"} rounded-md text-xs pb-0.5`}
        >
          {labels[check].name}
        </p>
      {:else}
        <button
          {disabled}
          title={labels[check].desc}
          class={`btn ${disabled || client?.checks?.includes(check) ? "btn-info" : "btn-neutral opacity-75"} btn-xs`}
          onclick={toggleCheck(check)}
        >
          {labels[check].name}
        </button>
      {/if}
    {/each}
  </div>

  {#if editing}
    <div class="divider my-1.5"></div>

    <div class="flex items-center gap-1.5 opacity-75 mb-3">
      <div class="text-xs grow pl-2.5">lifetimes</div>

      <Clock size="12" />

      <div class="text-xs italic pr-2.5">duration</div>
    </div>

    <div class="flex flex-col gap-1.5 w-full">
      {#each Object.keys(lifetimes) as type}
        <label class="input input-xs flex items-center gap-1.5 w-full">
          <div class="opacity-75 text-sm grow whitespace-nowrap">
            {lifetimes[type].name}
          </div>

          <input
            class="text-right min-w-0 text-sm"
            type="text"
            placeholder={lifetimes[type].placeholder}
            value={client[type]}
            oninput={(e) => change({ [type]: e.target.value })}
          />
        </label>
      {/each}
    </div>
  {/if}
</div>
