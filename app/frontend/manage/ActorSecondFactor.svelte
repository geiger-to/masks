<script>
  import Alert from "@/components/Alert.svelte";
  import ActorPassword from "./ActorPassword.svelte";
  import ActorEmails from "./ActorEmails.svelte";
  import ActorPhones from "./ActorPhones.svelte";
  import ActorHardwareKeys from "./ActorHardwareKeys.svelte";
  import ActorBackupCodes from "./ActorBackupCodes.svelte";
  import ActorTotpSecrets from "./ActorTotpSecrets.svelte";

  let { actor, change } = $props();
</script>

<div class="flex flex-col gap-1.5 mb-1.5">
  <Alert type={actor.secondFactor ? "info" : "warn"} class="mb-3">
    Secondary credentials are <b
      >{actor.secondFactor
        ? "enabled for this actor"
        : "not set up for this actor"}</b
    >.
  </Alert>

  <span class="text-xs opacity-75">phones</span>

  <ActorPhones {actor} />

  <span class="text-xs opacity-75 mt-3">hardware keys</span>

  <ActorHardwareKeys {actor} />

  <span class="text-xs opacity-75 mt-3">TOTP</span>

  <ActorTotpSecrets {actor} />

  <span class="text-xs opacity-75 mt-3">backup codes</span>

  <ActorBackupCodes {actor} />
</div>
