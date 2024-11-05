<script>
  import { Unlink, Send, Mail, Link2Off } from "lucide-svelte";
  import PromptHeader from "./PromptHeader.svelte";
  import PromptAlert from "./PromptAlert.svelte";
  import PromptIdentifier from "./PromptIdentifier.svelte";
  import PromptContinue from "./PromptContinue.svelte";
  import PasswordInput from "./PasswordInput.svelte";

  export let auth;
  export let identifier;
  export let loading;
  export let startOver;
  export let denied;
  export let loginLinks = auth?.settings?.email?.enabled;
  export let updates;

  let newPassword;
  let validPassword;
</script>

<div class="flex flex-col gap-6 mb-6">
  <div class="flex items-center gap-6">
    <PromptHeader heading="Login link cancelled">
      <div slot="subheading" class="max-w-[400px]">
        If you want to log in, enter your password or send another link...
      </div>
      <div slot="logo">
        <Link2Off size={60} class="text-warning" />
      </div>
    </PromptHeader>
  </div>
</div>

<div class="divider" />

<div class="flex flex-col md:flex-row md:items-center md:gap-4 text-center">
  <PromptContinue label="continue..." {loading} class={"btn-primary"} />

  <span class="text-xl ml-1.5 mt-3">
    to <b>{auth?.client?.name || "..."}</b>
  </span>
</div>
