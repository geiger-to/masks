<script>
  import { Send, MailSearch as Mail } from "lucide-svelte";
  import PromptPassword from "./PromptPassword.svelte";
</script>

<PromptPassword loginLinks={false} {...$$props}>
  <div class="ml-3 md:mt-0 mt-3">
    <div class="flex font-bold items-center gap-1.5 text-lg">
      <div class="rounded p-0.5 relative">
        <Mail size="15" class="text-info z-20" />
      </div>
      <span>Check your email...</span>
    </div>

    <p class="text-xs opacity-75 max-w-[250px]">
      Follow the login link in your email to log in without your password.
    </p>
  </div>
</PromptPassword>
