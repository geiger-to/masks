<script>
  import { run, preventDefault, stopPropagation } from "svelte/legacy";

  import _ from "lodash-es";
  import {
    AlertTriangle,
    Lock,
    Send,
    User,
    UserRoundPen,
    UserRoundCheck,
    UserCheck,
    Mail,
    MessagesSquare,
    ArrowLeft,
    MoveDownLeft,
    CornerLeftUp,
    Check,
    LockKeyhole,
    LockKeyholeOpen,
    Contact,
    MailPlus,
  } from "lucide-svelte";

  import Time from "svelte-time";
  import Alert from "@/components/Alert.svelte";
  import OnboardEmail from "./OnboardEmail.svelte";
  import Identicon from "@/components/Identicon.svelte";
  import EditableImage from "@/components/EditableImage.svelte";
  import PromptHeader from "./PromptHeader.svelte";
  import PromptIdentifier from "./PromptIdentifier.svelte";
  import PromptContinue from "./PromptContinue.svelte";
  import PasswordInput from "@/components/PasswordInput.svelte";
  import PromptBack from "./PromptBack.svelte";

  let { auth, authorize, ...props } = $props();

  let loading = $derived(props.loading);
  let actor = $state(auth?.actor);
  let name = $state(actor?.name);
  let nickname = $state(actor?.nickname);
  let loginEmail = actor?.loginEmail;
  let newEmail;
  let addingEmail;
  let password;
  let avatarUploaded = $derived(actor.avatar);
  let nicknameEnabled = $derived(auth?.settings?.nicknames?.enabled);
  let emailEnabled = $derived(auth?.settings?.emails?.enabled);
  let installName = $derived(auth?.settings?.name);
  let secondIdentifierType;
  let nameUpdated = $state(false);
  let nameTimeout;
  let newPassword = $state();
  let validPassword = $state();
  let passwordChanged = $state();

  let uploadAvatar = (file) => {
    authorize({
      event: "onboard:avatar",
      upload: file,
    });
  };

  run(() => {
    actor = auth.actor;
  });

  let updateName = _.debounce((e) => {
    authorize({
      event: "onboard:profile",
      updates: { name: e.target.value },
    });

    nameUpdated = true;

    if (nameTimeout) {
      clearTimeout(nameTimeout);
    }

    nameTimeout = setTimeout(() => {
      nameUpdated = false;
    }, 5000);
  }, 750);

  let changePassword = () => {
    authorize({
      event: "onboard:profile",
      updates: { password: newPassword },
    });

    passwordChanged = true;
  };
</script>

<PromptHeader
  heading="Before you go..."
  client={auth.client}
  redirectUri={auth.redirectUri}
  class="mb-6"
/>

<Alert type="success" class="mb-3">
  <b
    >👋 Welcome{#if installName}&nbsp;to <i>{installName}</i>{/if}!</b
  >

  Take a moment to confirm your account details before continuing.
</Alert>

<div class="flex flex-col gap-3">
  <div class="p-3 bg-base-100 rounded-lg flex items-center gap-3 mb-3">
    <div
      class="tooltip tooltip-right"
      data-tip={!avatarUploaded
        ? "Upload an avatar..."
        : "Change your avatar..."}
    >
      <EditableImage
        uploaded={uploadAvatar}
        params={{ actor_id: actor?.id }}
        src={actor?.avatar}
        name={actor?.identiconId}
        class="w-12 h-12 rounded-lg"
      />
    </div>

    <div class="grow">
      <div class="text-xl -mt-1 font-bold text-black dark:text-white">
        {actor.identifier}
      </div>
      <div class="text-xs flex items-baseline gap-1">
        <CornerLeftUp size="10" />
        your
        {actor.identifierType}
      </div>
    </div>

    <div
      class="tooltip md:tooltip-open tooltip-left"
      data-tip="Your unique identicon"
    >
      <div class="bg-black dark:bg-black rounded w-10 h-10 min-w-10 ml-0.5">
        <Identicon id={actor.identiconId} class="w-auto z-10" />
      </div>
    </div>
  </div>

  <div class="uppercase font-bold text-xs">your profile</div>

  <label class="input input-bordered flex items-center gap-3">
    <input
      class="w-full"
      placeholder="Add your name..."
      bind:value={name}
      oninput={updateName}
    />

    {#if loading}
      <span class="loading loading-spinner loading-sm"></span>
    {:else if nameUpdated}
      <UserRoundCheck class={"text-success"} />
    {:else}
      <UserRoundPen />
    {/if}
  </label>

  {#if auth?.client?.allowPasswords}
    <div class="flex items-center gap-1.5 mb-3">
      {#if actor.passwordChangeable}
        <PasswordInput
          disabled={passwordChanged}
          bind:value={newPassword}
          bind:valid={validPassword}
          placeholder="Change your password"
          class="grow min-w-0"
          {auth}
        />

        <button
          type="button"
          disabled={!validPassword}
          class="btn btn-success"
          onclick={stopPropagation(preventDefault(changePassword))}
        >
          {#if passwordChanged}
            <Check />
          {:else}
            change
          {/if}
        </button>
      {:else}
        <div
          class="bg-base-100 rounded-lg input input-bordered w-full flex items-center gap-3"
        >
          <div class="grow">
            <div class="text-sm truncate">
              Password <b
                >changed <Time
                  relative
                  timestamp={actor.passwordChangedAt}
                /></b
              >
            </div>
            <div class="text-xs opacity-75 truncate">
              Wait a bit to change it...
            </div>
          </div>

          <Lock />
        </div>
      {/if}
    </div>
  {/if}

  {#if actor.identifierType == "email" && nicknameEnabled}
    <label class="input input-bordered flex items-center gap-3 mb-3">
      <div class="text-xs">nickname</div>

      <input
        class=""
        placeholder="..."
        disabled={actor?.nickname}
        bind:value={nickname}
      />
    </label>
  {/if}

  <div class="flex items-center gap-3">
    <div class="uppercase font-bold text-xs grow whitespace-nowrap">
      your email
    </div>

    {#if auth?.warnings?.includes("login-email-limit")}
      <div class="text-xs italic truncate text-warning">
        you cannot add any more emails
      </div>
    {:else if actor && !actor?.loginEmails?.length}
      <div class="text-xs italic truncate">
        add an email for login and account recovery
      </div>
      <AlertTriangle size="16" class="text-warning" />
    {:else}
      <div class="text-xs italic truncate">
        used for login and account recovery
      </div>
    {/if}
  </div>

  <div class="flex flex-col gap-1.5">
    {#each actor?.loginEmails || [] as email (email.address)}
      {#key email.address}
        <OnboardEmail
          {auth}
          {authorize}
          {email}
          verifyClass="btn-xs -mr-1.5 btn-success btn-outline"
        />
      {/key}
    {/each}

    {#key actor?.loginEmails?.length}
      <OnboardEmail
        {auth}
        {authorize}
        inputClass="input-sm"
        btnClass="btn-sm"
      />
    {/key}
  </div>
</div>

<div class="flex flex-col md:flex-row md:items-center md:gap-4 mt-6">
  <button
    type="button"
    class="btn btn-lg btn-primary"
    onclick={stopPropagation(
      preventDefault(() => authorize({ event: "onboard:confirm" }))
    )}
  >
    continue
  </button>
</div>
