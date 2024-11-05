<script>
  import {
    Send,
    User,
    UserCheck,
    Mail,
    MailX,
    MailCheck,
    MailQuestion,
    MessagesSquare,
    ArrowLeft,
    MoveDownLeft,
    CornerLeftUp,
    Check,
    LockKeyhole,
    LockKeyholeOpen,
    Contact,
    MailPlus,
    Trash2,
  } from "lucide-svelte";

  import Time from "svelte-time";
  import Alert from "./Alert.svelte";
  import Identicon from "./Identicon.svelte";
  import EditableImage from "./EditableImage.svelte";
  import PromptHeader from "./PromptHeader.svelte";
  import PromptIdentifier from "./PromptIdentifier.svelte";
  import PromptContinue from "./PromptContinue.svelte";
  import PasswordInput from "./PasswordInput.svelte";
  import PromptBack from "./PromptBack.svelte";
  import CodeInput from "./CodeInput.svelte";

  export let auth;
  export let authorize;
  export let email;
  export let prefix = "onboard-email";
  export let deletable = false;

  let newEmail;
  let code, value, complete, verifying;

  let warning;
  let tooMany;

  $: tooMany = auth?.warnings?.includes(`${prefix}-limit`);
  $: warning = auth?.warnings?.includes(
    `invalid-email:${newEmail || email?.address}`
  );

  let deleteEmail = () => {
    authorize({
      event: `${prefix}:delete`,
      updates: { email: email.address },
    });
  };

  let verifyCode = (code) => {
    authorize({
      event: `${prefix}:verify-code`,
      updates: { code, email: email.address },
    });
  };

  let verifyEmail = () => {
    if (email?.verifyLink) {
      return (verifying = !verifying);
    }

    authorize({
      event: `${prefix}:verify`,
      updates: { email: email.address },
    });
  };

  let addEmail = () => {
    authorize({
      event: `${prefix}:add`,
      updates: { email: newEmail },
    });
  };

  $: if (complete) {
    verifyCode(value);
  }
</script>

{#if email}
  <div>
    <div
      class={[
        "flex items-center gap-3 dark:bg-black bg-base-100",
        "shadow py-1.5 px-3",
        email?.verifyLink ? "rounded-t-lg" : "rounded-lg",
      ].join(" ")}
    >
      <details class="dropdown ml-0.5">
        <summary class="cursor-pointer">
          {#if email?.verifiedAt}
            <MailCheck class="text-success" size="18" />
          {:else}
            <MailQuestion class="" size="18" />
          {/if}
        </summary>
        {#if email?.verifiedAt}
          <div
            class="animate-fade-in-fast dropdown-content bg-success text-success-content z-10 card card-compact p-1.5 px-3 shadow rounded-lg mt-1.5"
          >
            <span class="whitespace-nowrap text-sm font-bold">
              Verified&nbsp;<Time relative timestamp={email.verifiedAt} />
            </span>
          </div>
        {:else}
          <div
            class="animate-fade-in-fast dropdown-content bg-neutral text-neutral-content z-10 card card-compact p-1.5 px-3 shadow rounded-lg mt-1.5"
          >
            <span class="whitespace-nowrap text-sm font-bold">
              Unverified
            </span>
          </div>
        {/if}
      </details>

      <span
        class="font-bold grow dark:text-white text-black truncate text-sm mb-0.5"
      >
        {email.address}
      </span>

      {#if !email?.verifiedAt && !email?.verifyLink}
        <button
          type="button"
          class={`btn w-auto ${$$props.verifyClass}`}
          on:click|preventDefault|stopPropagation={verifyEmail}>verify</button
        >
      {/if}

      {#if deletable}
        <button
          type="button"
          class="btn btn-link text-error btn-xs"
          on:click|preventDefault|stopPropagation={deleteEmail}
        >
          <Trash2 size="18" />
        </button>
      {/if}
    </div>

    {#if email.verifyLink}
      <div class="flex flex-col">
        <div
          class="text-sm text-left border-x dark:border-neutral border-neutral-content border-dashed px-3 py-3 bg-base-200"
        >
          <div class="pl-1.5">
            Check your email for a 7-character verification code. Enter it below
            to verify your email address...
          </div>
        </div>
        <CodeInput {auth} bind:code bind:value bind:complete />
      </div>
    {/if}
  </div>
{:else}
  <div>
    <div class={[warning ? "animate-denied" : ""].join(" ")}>
      <div class={`flex items-center gap-1.5 grow ${$$props.class}`}>
        <label
          class={`input input-ghost flex items-center gap-3 grow ${$$props.inputClass} input-bordered my-0 min-w-0 w-0`}
        >
          <MailPlus size="20" class="" />
          <input
            class="w-full"
            placeholder="Add an email address..."
            bind:value={newEmail}
            disabled={tooMany}
          />
        </label>

        <button
          type="button"
          class={`btn btn-success ${$$props.btnClass} ${warning ? "btn-warning" : ""}`}
          on:click|preventDefault|stopPropagation={addEmail}
          disabled={tooMany || !newEmail?.includes("@")}
        >
          add email
        </button>
      </div>
    </div>
  </div>
{/if}
