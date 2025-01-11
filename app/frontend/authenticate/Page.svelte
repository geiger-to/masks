<script>
  import { run } from "svelte/legacy";

  import { createConsumer } from "@rails/actioncable";
  import { AlertTriangle, RotateCcw } from "lucide-svelte";
  import Identicon from "@/components/Identicon.svelte";
  import PasswordInput from "@/components/PasswordInput.svelte";
  import PromptDevice from "./PromptDevice.svelte";
  import PromptIdentify from "./PromptIdentify.svelte";
  import PromptCredentials from "./PromptCredentials.svelte";
  import PromptSSO from "./PromptSSO.svelte";
  import PromptSSOError from "./PromptSSOError.svelte";
  import PromptSSOAccept from "./PromptSSOAccept.svelte";
  import PromptSSOLink from "./PromptSSOLink.svelte";
  import PromptSecondFactor from "./PromptSecondFactor.svelte";
  import PromptResetPassword from "./PromptResetPassword.svelte";
  import PromptVerifyEmail from "./PromptVerifyEmail.svelte";
  import PromptLoginLink from "./PromptLoginLink.svelte";
  import PromptLoginCode from "./PromptLoginCode.svelte";
  import PromptLoading from "./PromptLoading.svelte";
  import PromptLoadingError from "./PromptLoadingError.svelte";
  import PromptError from "./PromptError.svelte";
  import PromptSuccess from "./PromptSuccess.svelte";
  import PromptAccessDenied from "./PromptAccessDenied.svelte";
  import PromptMissingScopes from "./PromptMissingScopes.svelte";
  import PromptInvalidRedirectUri from "./PromptInvalidRedirectUri.svelte";
  import PromptUnsupportedResponseType from "./PromptUnsupportedResponseType.svelte";
  import PromptMissingNonce from "./PromptMissingNonce.svelte";
  import PromptExpiredState from "./PromptExpiredState.svelte";
  import PromptAuthorize from "./PromptAuthorize.svelte";
  import PromptOnboard from "./PromptOnboard.svelte";
  import { onMount } from "svelte";
  import { mutationStore, gql, getContextClient } from "@urql/svelte";
  import Time from "svelte-time";
  import AuthenticateQuery from "../authenticate.graphql?raw";

  let { backend, auth = $bindable() } = $props();

  let consumer = createConsumer();
  let client = getContextClient();
  let mutation = $state();

  const authorize = (vars) => {
    return new Promise((res, rej) => {
      mutation = mutationStore({
        client,
        query: gql`
          ${AuthenticateQuery}
        `,
        variables: { input: { id: auth.id, ...vars } },
      });

      mutation.subscribe((result) => {
        loading = !result || result.fetching;

        if (loading) {
          return;
        }

        auth = result.data?.authenticate;
        identifier = auth?.identifier;
        loadingError = result.error;

        if (auth) {
          res(auth);
        }
      });
    });
  };

  let loading = $state(true);
  let identifier = $state();
  let password = $state();
  let updates = $state();
  let settings = $derived(auth?.settings || backend?.settings);

  const startOver = () => {
    auth.identifier = identifier = null;
    auth.password = password = null;
    auth.errorCode = null;
    auth.errorMessage = null;
    auth.prompt = "identify";
  };

  const continueAuth = (args) => {
    return (e) => {
      e.preventDefault();

      let eventName = e.submitter.dataset.event;

      if (eventName) {
        args.event = eventName;
      }

      authorize(args);
    };
  };

  const onUpdate = (v) => {
    if (v != updates) {
      updates = v;
    }
  };

  if (auth?.id) {
    authorize({});
  }

  let prompts = {
    identify: PromptIdentify,
    device: PromptDevice,
    credentials: PromptCredentials,
    sso: PromptSSO,
    "sso:error": PromptSSOError,
    "sso:accept": PromptSSOAccept,
    "sso:link": PromptSSOLink,
    "second-factor": PromptSecondFactor,
    "login-code": PromptLoginCode,
    "login-link": PromptLoginLink,
    "verify-email": PromptVerifyEmail,
    "reset-password": PromptResetPassword,
    "invalid-redirect": PromptInvalidRedirectUri,
    "missing-scopes": PromptMissingScopes,
    "missing-nonce": PromptMissingNonce,
    "expired-state": PromptExpiredState,
    "access-denied": PromptAccessDenied,
    authorize: PromptAuthorize,
    onboard: PromptOnboard,
    success: PromptSuccess,
    unsupported_response_type: PromptUnsupportedResponseType,
  };

  let loadingError = $state();

  let computePrompt = (backend, auth, loading, error) => {
    if (prompts[backend?.prompt]) {
      return prompts[backend?.prompt];
    }

    if (error) {
      return PromptLoadingError;
    }

    if (prompts[auth?.prompt]) {
      return prompts[auth.prompt];
    }

    return PromptLoading;
  };

  let defaultEvent = $state();
  let currentEvent = (name) => {
    defaultEvent = name;
  };

  let hasLogo = $derived(settings?.lightLogoUrl || settings?.darkLogoUrl);

  const Prompt = $derived(computePrompt(backend, auth, loading, loadingError));
</script>

<div
  class="background animate-fade-in flex flex-col min-h-full md:p-3 px-[5px] items-center justify-center"
>
  <div class="w-full md:w-[500px] mx-auto rounded-b-2xl shadow-2xl">
    <div
      class={`bg-white dark:bg-black !bg-opacity-85 h-[25px] md:h-[32px] rounded-t-2xl w-full relative border-t border-white dark:border-opacity-20 border-opacity-50`}
    ></div>
    <div
      class="md:w-[500px] bg-white dark:bg-black !bg-opacity-85 w-full md:px-8 pb-5 px-5"
    >
      {#snippet logo()}
        {#if hasLogo}
          <div class="max-w-[300px]">
            {#if settings?.lightLogoUrl}
              <img
                alt={`${settings?.theme?.name} logo`}
                src={settings?.lightLogoUrl}
                class="object-scale-down h-10 rounded dark:hidden"
              />
            {/if}

            {#if settings?.darkLogoUrl}
              <img
                alt={`${settings?.theme?.name} logo`}
                src={settings?.darkLogoUrl}
                class="object-scale-down h-10 rounded hidden dark:block"
              />
            {/if}
          </div>
        {:else}
          <p
            class="font-bold grow text-left text-lg md:text-xl group-hover:underline group-focus:underline"
          >
            {settings?.theme?.name}
          </p>
        {/if}
      {/snippet}

      {#if settings?.theme?.url}
        <a
          href={settings?.theme?.url}
          class="flex items-center gap-4 group !outline-none"
        >
          {@render logo()}
        </a>
      {:else}
        {@render logo()}
      {/if}

      <div class="grow"></div>
    </div>
    <div class="w-full md:w-[500px] mx-auto relative rounded-b-2xl shadow-xl">
      <div
        class="bg-white dark:bg-black !bg-opacity-85 w-full min-h-[200px] md:w-[500px] mx-auto"
      >
        <div class="px-5 md:px-8">
          <Prompt
            {settings}
            {backend}
            {auth}
            {startOver}
            {authorize}
            {loading}
            {loadingError}
            vars={updates}
            updates={onUpdate}
            setEvent={currentEvent}
            {identifier}
            {password}
          />
        </div>
      </div>
      <div
        class={`bg-white dark:bg-black !bg-opacity-85 h-[30px] overflow-hidden rounded-b-2xl`}
      ></div>
    </div>
  </div>
</div>
