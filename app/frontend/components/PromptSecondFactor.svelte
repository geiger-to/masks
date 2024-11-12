<script>
  import _ from "lodash-es";

  import {
    AlertTriangle,
    KeySquare,
    Binary,
    QrCode,
    Phone,
    Fingerprint,
  } from "lucide-svelte";

  import Alert from "./Alert.svelte";
  import PromptHeader from "./PromptHeader.svelte";
  import PromptIdentifier from "./PromptIdentifier.svelte";
  import PromptContinue from "./PromptContinue.svelte";
  import FactorWebauthn from "./FactorWebauthn.svelte";
  import FactorTotp from "./FactorTotp.svelte";
  import FactorPhoneNumber from "./FactorPhoneNumber.svelte";
  import FactorBackupCodes from "./FactorBackupCodes.svelte";
  import Card from "./Card.svelte";

  export let auth;
  export let loading;

  let enabled;
  $: enabled = auth?.actor?.secondFactor;

  let securityKeys;
  $: securityKeys = auth?.actor?.secondFactors?.filter(
    (f) => f.__typename == "WebauthnCredential"
  );

  let phones;
  $: phones = auth?.actor?.secondFactors?.filter(
    (f) => f.__typename == "Phone"
  );

  let totp;
  $: totp = auth?.actor?.secondFactors?.filter(
    (f) => f.__typename == "OtpSecret"
  );

  let backupCodes;
  $: backupCodes = auth?.actor?.savedBackupCodesAt;

  let enabledFactors;

  $: enabledFactors = [
    securityKeys?.length
      ? {
          component: FactorWebauthn,
          choose: "security key",
        }
      : null,
    phones?.length
      ? {
          component: FactorPhoneNumber,
          choose: "phone number",
        }
      : null,
    totp?.length
      ? {
          component: FactorTotp,
          choose: "one-time code",
        }
      : null,
  ].filter(Boolean);

  let secondFactor;
  $: secondFactor = auth?.actor?.secondFactors?.length;

  let canContinue;
  $: canContinue = !enabled && backupCodes && secondFactor;

  let heading;
  $: heading = enabled
    ? "Verify your credentials..."
    : "Add your credentials...";

  let factors = [
    FactorWebauthn,
    FactorPhoneNumber,
    FactorTotp,
    FactorBackupCodes,
  ];

  let factor;
  let defaultFactor;
  let previousFactor;

  $: defaultFactor = securityKeys?.length
    ? FactorWebauthn
    : phones?.length
      ? FactorPhoneNumber
      : totp?.length
        ? FactorTotp
        : FactorBackupCodes;

  let switchFactor = (v) => {
    previousFactor = factor;
    factor = v;
  };

  let cancelFactor = () => {
    switchFactor(null);
  };

  let currentFactor;
  $: currentFactor = factor || defaultFactor;

  let lockedTab;
  let setLocked = (v) => {
    lockedTab = v;
  };

  $: console.log(enabledFactors);
</script>

<div class="flex flex-col divide-y divide-base-100 divide-dotted">
  <div>
    <PromptHeader {heading} client={auth.client} class="mb-6" />
    <PromptIdentifier {auth} class="my-3" />

    {#if !secondFactor}
      <Alert type="info" icon={KeySquare}>
        Set up one or more of the following extra credentials to secure your
        account.
      </Alert>
    {/if}

    {#if enabled}
      <div>
        {#if Object.values(enabledFactors).length > 1}
          <div class="overflow-auto pt-1.5 pl-3">
            <div
              role="tablist"
              class="tabs tabs-bordered tabs-xs justify-start w-full"
            >
              {#each Object.values(enabledFactors) as { component, choose }, index}
                <a
                  on:click|preventDefault|stopPropagation={() =>
                    switchFactor(lockedTab ? currentFactor : component)}
                  role="tab"
                  class={`${component == currentFactor ? "tab tab-active" : lockedTab ? "tab tab-disabled" : "tab opacity-75"} whitespace-nowrap pb-6 text-left`}
                  >{choose}</a
                >
              {/each}
            </div>
          </div>
        {/if}
        <svelte:component
          this={factor || defaultFactor}
          {...$$props}
          authorizing
          {setLocked}
        />
      </div>

      <div class="text-center pt-1.5 rounded mt-3 text-xs opacity-75">
        {#if currentFactor == FactorBackupCodes}
          <button
            type="button"
            class="btn btn-xs text-error"
            on:click|stopPropagation|preventDefault={() =>
              switchFactor(previousFactor || defaultFactor)}>cancel</button
          >
        {:else}
          <button
            type="button"
            class="btn btn-xs"
            on:click|stopPropagation|preventDefault={() =>
              switchFactor(FactorBackupCodes)}>enter a backup code</button
          >
        {/if}
      </div>
    {/if}
  </div>

  {#if !enabled}
    {#each factors as component}
      <svelte:component this={component} {...$$props} />
    {/each}

    <Card class="-mt-3 pt-6 pb-0">
      <PromptContinue
        {auth}
        disabled={loading || !canContinue}
        class="btn-primary"
        event="second-factor:enable"
      />
    </Card>
  {/if}
</div>
