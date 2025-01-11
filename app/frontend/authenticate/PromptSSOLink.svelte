<script>
  import Icon from "@iconify/svelte";
  import { Link, Unlink, X, Send, Mail } from "lucide-svelte";
  import Alert from "@/components/Alert.svelte";
  import PromptHeader from "./PromptHeader.svelte";
  import SSOHeader from "./SSOHeader.svelte";
  import PromptIdentifier from "./PromptIdentifier.svelte";
  import PromptContinue from "./PromptContinue.svelte";
  import PasswordInput from "@/components/PasswordInput.svelte";
  import { iconifyProvider, redirectTimeout } from "@/util.js";

  let {
    auth,
    authorize,
    identifier,
    loading = $bindable(),
    startOver,
  } = $props();

  let { sso, info } = auth.extras;
  let { provider } = sso;
  let failed = $derived(auth?.warnings?.includes("invalid-sso"));
</script>

<div class="animate-fade-in-1s px-6">
  <SSOHeader
    {auth}
    {provider}
    errors={failed
      ? [`Your ${provider.name} account is already in use or invalid.`]
      : null}
  >
    {#snippet heading()}
      {#if failed}
        Unable to link your
        <b class="font-bold">{provider?.name}</b> account
      {:else}
        Link your
        <b class="font-bold">{provider?.name}</b> account?
      {/if}
    {/snippet}

    {#snippet alert()}
      {#if failed}
        <Alert
          type="error"
          errors={[
            `Your ${provider.name} account is already in use or invalid.`,
          ]}
          class="mb-6"
        />
      {:else if sso?.linked}
        <Alert type="success" class="mb-6">
          {#snippet children()}
            <b>Accounts linked.</b> You can now use your {provider.name} account
            to log in.
          {/snippet}
        </Alert>
      {/if}
    {/snippet}
  </SSOHeader>

  <div class="flex flex-col gap-3 mb-10">
    <div class={`divider my-0 ${failed ? "text-error" : ""}`}>
      <div>
        {#if failed}<Unlink size="14" />{:else}<Link size="14" />{/if}
      </div>
    </div>

    <Alert type="info">
      <div class="flex items-center gap-3 text-xl font-bold">
        <div
          class="bg-info text-info-content rounded-full overflow-hidden w-10 h-10 flex items-center justify-center"
        >
          {#if info?.image}
            <img src={info.image} />
          {:else}
            <Icon icon={iconifyProvider(provider)} />
          {/if}
        </div>

        <div>
          {info?.name || info?.email || info?.nickname}
        </div>
      </div>
    </Alert>
  </div>

  <div class="flex items-center gap-3 w-full justify-center pb-8">
    {#if sso?.linked}
      <PromptContinue label={`Continue`} type="submit" {authorize} />
    {:else}
      <PromptContinue
        confirm="Are you sure you want to link accounts?"
        label={`Link`}
        deniedLabel={"Link"}
        type="submit"
        disabled={failed}
        denied={failed}
        class={failed ? "btn-error" : "btn-info"}
        event={"sso:link"}
        {authorize}
      />

      <PromptContinue
        confirm="Are you sure you want to start over?"
        label={`Skip`}
        iconClass="opacity-75"
        type="submit"
        event={"sso:reset"}
        {authorize}
      />
    {/if}
  </div>
</div>
