<script>
  import { preventDefault, stopPropagation } from "svelte/legacy";

  import _ from "lodash-es";

  import {
    AlertTriangle,
    KeySquare,
    Binary,
    QrCode,
    Phone,
    Fingerprint,
  } from "lucide-svelte";

  import Alert from "@/components/Alert.svelte";
  import PromptHeader from "./PromptHeader.svelte";
  import PromptIdentifier from "./PromptIdentifier.svelte";
  import PromptContinue from "./PromptContinue.svelte";
  import FactorWebauthn from "./FactorWebauthn.svelte";
  import FactorTotp from "./FactorTotp.svelte";
  import FactorPhoneNumber from "./FactorPhoneNumber.svelte";
  import FactorBackupCodes from "./FactorBackupCodes.svelte";
  import Card from "@/components/Card.svelte";

  let { loading = $bindable(), ...props } = $props();
  let { authorize } = props;

  let auth = $derived(props.auth);
  let enabled = $derived(auth?.actor?.secondFactor);

  let securityKeys = $derived(
    auth?.actor?.secondFactors?.filter((f) => f.__typename == "HardwareKey")
  );

  let phones = $derived(
    auth?.actor?.secondFactors?.filter((f) => f.__typename == "Phone")
  );

  let totp = $derived(
    auth?.actor?.secondFactors?.filter((f) => f.__typename == "OtpSecret")
  );

  let backupCodes = $derived(auth?.actor?.savedBackupCodesAt);

  let enabledFactors = $derived(
    [
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
    ].filter(Boolean)
  );

  let secondFactor = $derived(auth?.actor?.secondFactors?.length);

  let canContinue = $derived(!enabled && backupCodes && secondFactor);

  let heading = $derived(
    enabled ? "Verify your credentials..." : "Add your credentials..."
  );

  let factors = [
    FactorWebauthn,
    FactorPhoneNumber,
    FactorTotp,
    FactorBackupCodes,
  ];

  let factor = $state();
  let defaultFactor = $derived(
    securityKeys?.length
      ? FactorWebauthn
      : phones?.length
        ? FactorPhoneNumber
        : totp?.length
          ? FactorTotp
          : FactorBackupCodes
  );
  let previousFactor = $state();

  let switchFactor = (v) => {
    previousFactor = factor;
    factor = v;
  };

  let cancelFactor = () => {
    switchFactor(null);
  };

  let currentFactor = $derived(factor || defaultFactor);

  let lockedTab = $state();
  let setLocked = (v) => {
    lockedTab = v;
  };
</script>

<div class="flex flex-col divide-y divide-base-100 divide-dotted">
  <div>
    <PromptHeader {heading} client={auth.client} class="mb-6" />

    {#if !secondFactor}
      <Alert type="info" icon={KeySquare} class="mb-3">
        Set up one or more of the following extra credentials to secure your
        account.
      </Alert>
    {/if}

    <PromptIdentifier {auth} class="my-3 mb-4" />

    {#if enabled}
      {@const Factor = factor || defaultFactor}
      <div>
        {#if Object.values(enabledFactors).length > 1}
          <div class="overflow-auto pt-1.5 pl-3">
            <div
              role="tablist"
              class="tabs tabs-bordered tabs-xs justify-start w-full"
            >
              {#each Object.values(enabledFactors) as { component, choose }, index}
                <button
                  onclick={stopPropagation(
                    preventDefault(() =>
                      switchFactor(lockedTab ? currentFactor : component)
                    )
                  )}
                  type="button"
                  role="tab"
                  class={`${component == currentFactor ? "tab tab-active" : lockedTab ? "tab tab-disabled" : "tab opacity-75"} whitespace-nowrap pb-6 text-left`}
                  >{choose}</button
                >
              {/each}
            </div>
          </div>
        {/if}
        <Factor {...props} authorizing {setLocked} />
      </div>

      <div class="text-center pt-1.5 rounded mt-3 text-xs opacity-75">
        {#if currentFactor == FactorBackupCodes}
          <button
            type="button"
            class="btn btn-xs text-error"
            onclick={stopPropagation(
              preventDefault(() =>
                switchFactor(previousFactor || defaultFactor)
              )
            )}>cancel</button
          >
        {:else}
          <button
            type="button"
            class="btn btn-xs"
            onclick={stopPropagation(
              preventDefault(() => switchFactor(FactorBackupCodes))
            )}>enter a backup code</button
          >
        {/if}
      </div>
    {/if}
  </div>

  {#if !enabled}
    {#each factors as Factor}
      <Factor {...props} />
    {/each}

    <Card class="-my-3 pt-6 pb-0">
      <PromptContinue
        {auth}
        {loading}
        {authorize}
        event="second-factor:enable"
        disabled={!canContinue}
        class="btn-primary"
      />
    </Card>
  {/if}
</div>
