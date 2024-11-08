<script>
  import _ from "lodash-es";

  import { Binary, QrCode, Phone, Fingerprint } from "lucide-svelte";

  import Alert from "./Alert.svelte";
  import PromptHeader from "./PromptHeader.svelte";
  import OnboardHardwareKey from "./OnboardHardwareKey.svelte";
  import OnboardAuthenticatorApp from "./OnboardAuthenticatorApp.svelte";
  import OnboardPhoneNumber from "./OnboardPhoneNumber.svelte";
  import OnboardBackupCodes from "./OnboardBackupCodes.svelte";

  export let auth;

  let heading = auth?.actor?.secondFactor
    ? "Enter another credential..."
    : "Add secondary credentials...";
</script>

<PromptHeader {heading} client={auth.client} class="mb-6" />

<Alert type="info">
  Set up one or more of the following secondary credentials to secure your
  account.
</Alert>

<div class="flex flex-col gap-3">
  <OnboardHardwareKey {...$$props} />
  <OnboardPhoneNumber {...$$props} />
  <OnboardAuthenticatorApp {...$$props} />
  <OnboardBackupCodes {...$$props} />
</div>
