<script>
  import _ from "lodash-es";

  import {
    Info,
    X,
    Check,
    Download,
    Copy,
    Binary,
    QrCode,
    Phone,
    History,
    Fingerprint,
  } from "lucide-svelte";
  import { base32crockford } from "@scure/base";

  import PasswordInput from "./PasswordInput.svelte";
  import Time from "./Time.svelte";
  import Alert from "./Alert.svelte";
  import Card from "./Card.svelte";

  export let auth;
  export let authorize;
  export let authorizing;

  let copied;
  let generating;
  let generated;
  let entering;

  $: generated = auth?.actor?.savedBackupCodesAt;

  function generateCodes(count, length) {
    const codes = new Set();

    while (codes.size < count) {
      const randomBytes = new Uint8Array(Math.ceil((length * 5) / 8));
      crypto.getRandomValues(randomBytes);

      const code = base32crockford.encode(randomBytes).slice(0, length);
      codes.add(code);
    }

    return Array.from(codes);
  }

  function downloadCodes(codes) {
    const blob = new Blob([codes.join("\n")], { type: "text/plain" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = `${[auth?.settings?.name, "codes"].filter(Boolean).join("-")}.txt`;
    link.click();
    URL.revokeObjectURL(url);
  }

  function saveCodes(codes) {
    authorize({ event: "backup-codes:replace", updates: { codes } }).then(
      () => {
        generating = false;
      }
    );
  }

  async function copyCodes(codes) {
    try {
      await navigator.clipboard.writeText(codes.join("\n"));
      copied = true;
    } catch (error) {
      alert("Failed to copy codes...");
    }
  }

  let codes = generateCodes(10, 20);
  let enableCta;
  let denied;
  let code;

  let verifyCode = () => {
    authorize({ event: "backup-code:verify", updates: { code } }).then(
      (result) => {
        if (result?.warnings?.length) {
          denied = true;
        }
      }
    );
  };

  $: if (code) {
    denied = false;
  }

  let warnEntry;

  $: warnEntry =
    !auth?.actor?.savedBackupCodesAt && auth?.actor?.secondFactors?.length;
  $: enableCta = auth?.actor?.savedBackupCodesAt ? "save" : "enable";
</script>

{#if authorizing}
  <Alert type="neutral">
    <div class="flex items-center gap-3 mb-1.5">
      <div
        class="flex items-center gap-1.5 p-1 text-xs font-bold bg-base-300 px-2 rounded-lg"
      >
        <div class="whitespace-nowrap">
          {#if auth.actor.remainingBackupCodes == 1}
            1 remaining
          {:else}
            {auth?.actor?.remainingBackupCodes} remaining
          {/if}
        </div>
      </div>

      {#if denied}
        <span class="text-xs text-error"> Invalid code. try again... </span>
      {:else}
        <div
          class="text-xs whitespace-nowrap flex items-center gap-1.5 opacity-75 hidden md:block"
        >
          <span>
            Your codes were generated <Time
              timestamp={auth.actor.savedBackupCodesAt}
            />.
          </span>
        </div>
      {/if}
    </div>

    <div class="flex items-center gap-3 w-full mb-1.5">
      <PasswordInput
        inputClass="w-full grow"
        class={[
          "input-neutral bg-transparent input-lg w-full",
          denied ? "animate-denied input-error" : "",
        ].join(" ")}
        placeholder={`Enter a backup code...`}
        bind:value={code}
      >
        <button
          slot="end"
          class="btn btn-sm px-1.5 btn-success -mr-1.5"
          disabled={!code || denied}
          on:click|stopPropagation|preventDefault={verifyCode}
        >
          {#if denied}
            <X />
          {:else}
            <Check />
          {/if}
        </button>
      </PasswordInput>
    </div>
  </Alert>
{:else}
  <Card>
    <div class="flex items-center gap-1.5 py-1">
      <History size="16" />
      <div class="text-xs font-bold grow">Backup codes</div>
    </div>
    <div class="flex items-end gap-3 mb-3">
      <p class="grow opacity-75 text-sm">
        {#if generating}
          Keep the following backup codes in a safe place, then press <b
            >{enableCta}</b
          >. {#if auth?.actor?.savedBackupCodesAt}
            Your old backup codes will no longer work.
          {/if}
        {:else if generated}
          <div>
            <p class="dark:text-white text-black mb-0.5">
              {auth?.actor?.remainingBackupCodes} remaining backup codes
            </p>
            <p class="text-xs">
              generated <Time
                style="long"
                timestamp={auth?.actor?.savedBackupCodesAt}
              />
            </p>
          </div>
        {:else}
          Generate backup codes for times when you lose access to other
          secondary credentials.

          {#if warnEntry}
            <span class="text-warning">Backup codes are <b>required</b>.</span>
          {/if}
        {/if}
      </p>

      {#if generating}
        <div class="flex flex-col items-center">
          <button
            disabled={!generating}
            class="btn btn-sm btn-success"
            type="button"
            on:click|preventDefault|stopPropagation={() => saveCodes(codes)}
          >
            {enableCta}
          </button>
          {#if auth?.actor?.savedBackupCodesAt}
            <button
              class="btn btn-sm btn-link whitepsace-nowrap !btn-neutral flex items-center gap-0"
              type="button"
              on:click|preventDefault|stopPropagation={() =>
                (generating = false)}>cancel</button
            >
          {/if}
        </div>
      {:else if generated}
        <button
          class="btn btn-xs"
          type="button"
          on:click|preventDefault|stopPropagation={() => (generating = true)}
          >generate new codes</button
        >
      {/if}
    </div>

    {#if generating}
      <div class="p-3 bg-base-100 rounded-lg shadow-inner mb-3">
        <div class="flex gap-3 items-center mb-3">
          <button
            class="btn btn-sm grow"
            type="button"
            on:click|preventDefault|stopPropagation={() => downloadCodes(codes)}
            ><Download size="14" /> download</button
          >
          <button
            class="btn btn-sm grow"
            type="button"
            on:click|preventDefault|stopPropagation={() => copyCodes(codes)}
            ><Copy size="14" /> copy</button
          >
        </div>

        <div class="overflow-auto">
          <pre
            class="leading-loose tracking-widest font-mono text-center">{codes.join(
              "\n"
            )}</pre>
        </div>
      </div>
    {:else if !generated}
      <button
        class={`btn btn-sm w-full mb-3 ${warnEntry ? "btn-warning" : ""}`}
        type="button"
        on:click|preventDefault|stopPropagation={() => (generating = true)}
        >generate backup codes</button
      >
    {/if}
  </Card>
{/if}
