<script>
  import _ from "lodash-es";

  import {
    Download,
    Copy,
    Binary,
    QrCode,
    Phone,
    History,
    Fingerprint,
  } from "lucide-svelte";
  import { base32crockford } from "@scure/base";

  import Time from "./Time.svelte";
  import Card from "./Card.svelte";

  export let auth;
  export let authorize;

  let copied;
  let generating;
  let generated;

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
    authorize({ event: "backup-codes:add", updates: { codes } });
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
</script>

<Card>
  <div class="flex items-center gap-1.5 py-1">
    <History size="16" />
    <div class="text-xs font-bold grow">Backup codes</div>
  </div>

  <div class="flex items-end gap-3 mb-3">
    <p class="grow opacity-75 text-sm">
      {#if generating}
        Keep the following backup codes in a safe place, then press <b>enable</b
        >.
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
        Generate backup codes for times when you lose access to other secondary
        credentials.
      {/if}
    </p>

    {#if generating}
      <button
        disabled={!generating}
        class="btn btn-sm btn-success"
        type="button"
        on:click|preventDefault|stopPropagation={() => saveCodes(codes)}
        >enable</button
      >
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
    <div class="p-3 bg-base-100 rounded-lg shadow-inner">
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
      class="btn btn-sm w-full"
      type="button"
      on:click|preventDefault|stopPropagation={() => (generating = true)}
      >generate backup codes</button
    >
  {/if}
</Card>
