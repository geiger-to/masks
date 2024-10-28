<script>
  import {
    User,
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
  } from "lucide-svelte";

  import Time from "svelte-time";
  import Identicon from "./Identicon.svelte";
  import EditableImage from "./EditableImage.svelte";
  import PromptHeader from "./PromptHeader.svelte";
  import PromptIdentifier from "./PromptIdentifier.svelte";
  import PromptContinue from "./PromptContinue.svelte";
  import PasswordInput from "./PasswordInput.svelte";
  import PromptBack from "./PromptBack.svelte";

  export let auth;
  export let loading;
  export let startOver;

  let actor;

  let avatarUploaded;
  let emailEnabled;
  let emailAdded;
  let installName;
  let secondIdentifierType;

  $: installName = auth?.settings?.name;
  $: actor = auth.actor;
  $: emailEnabled = auth?.settings?.email?.enabled;
  $: emailAdded = emailEnabled && actor.loginEmail;
  $: avatarUploaded = actor.avatar;
</script>

<PromptHeader
  heading="Before you go..."
  client={auth.client}
  redirectUri={auth.redirectUri}
/>

<div
  class="text-xl mb-6 p-6 py-3 rounded-lg flex items-center gap-3 alert text-left bg-base-100"
>
  <div class="grow">
    <b
      >👋 Welcome{#if installName}&nbsp;to <i>{installName}</i>{/if}!</b
    >

    Verify your profile before continuing...
  </div>
</div>

<div class="flex flex-col gap-1">
  <div class="p-3 bg-base-200 rounded-lg flex items-center gap-3">
    <div
      class="tooltip tooltip-right md:tooltip-bottom"
      data-tip={!avatarUploaded
        ? "Upload an avatar..."
        : "Change your avatar..."}
    >
      <EditableImage
        endpoint="/upload/avatar"
        params={{ actor_id: actor.id }}
        src={actor?.avatar}
        name={actor?.identiconId}
        class="w-12 h-12 rounded-lg"
      />
    </div>

    <div class="grow">
      <div class="text-xl -mt-1 font-bold">
        {actor.identifier}
      </div>
      <div class="text-xs flex items-baseline gap-1">
        <CornerLeftUp size="10" /> Your {actor.identifierType}
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

  <label class="input flex items-center gap-3 mt-1.5">
    <div class="text-xs mt-[5px]">Your name</div>

    <input class="" placeholder="..." />
  </label>

  <label class="input flex items-center gap-3">
    <div class="text-xs mt-[5px]">Your email</div>

    <input class="" placeholder="..." bind:value={actor.loginEmail} />
  </label>

  <label class="input flex items-center gap-3">
    <div class="text-xs mt-[5px]">Password</div>

    <Time relative timestamp={actor.setPasswordAt} />
  </label>

  <div class="p-3 bg-base-100 rounded-lg mb-6">
    <div class="flex gap-3 items-center">
      <div class="">
        <LockKeyholeOpen />
      </div>

      <div class="grow">
        <div class="-mt-1">Credentials</div>
        <div class="text-xs flex items-baseline gap-1">password</div>
      </div>

      <button class="btn btn-neutral btn-sm"> manage... </button>
    </div>
  </div>
</div>

<div class="flex gap-6 items-center">
  <a class="btn btn-lg btn-primary" href="/profile"> save </a>

  <span class="opacity-75 text-lg ml-1.5"> or </span>

  <PromptContinue
    event="onboard"
    class="px-0 w-auto !btn-neutral btn-link"
    label="continue without changes..."
  />
</div>
