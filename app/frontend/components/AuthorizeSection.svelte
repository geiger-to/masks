<script>
  import { createConsumer } from "@rails/actioncable";
  import { AlertTriangle, RotateCcw } from "lucide-svelte";
  import Identicon from "./Identicon.svelte";
  import PasswordInput from "./PasswordInput.svelte";
  import PromptCredential from "./PromptCredential.svelte";
  import PromptResetPassword from "./PromptResetPassword.svelte";
  import PromptVerifyEmail from "./PromptVerifyEmail.svelte";
  import PromptLoginLink from "./PromptLoginLink.svelte";
  import PromptLoginCode from "./PromptLoginCode.svelte";
  import PromptLogin from "./PromptLogin.svelte";
  import PromptLoading from "./PromptLoading.svelte";
  import PromptLoadingError from "./PromptLoadingError.svelte";
  import PromptSuccess from "./PromptSuccess.svelte";
  import PromptAccessDenied from "./PromptAccessDenied.svelte";
  import PromptScopesRequired from "./PromptScopesRequired.svelte";
  import PromptInvalidIdentifier from "./PromptInvalidIdentifier.svelte";
  import PromptInvalidRequest from "./PromptInvalidRequest.svelte";
  import PromptInvalidRedirectUri from "./PromptInvalidRedirectUri.svelte";
  import PromptUnsupportedResponseType from "./PromptUnsupportedResponseType.svelte";
  import PromptNonceRequired from "./PromptNonceRequired.svelte";
  import PromptAuthorize from "./PromptAuthorize.svelte";
  import PromptOnboard from "./PromptOnboard.svelte";
  import { onMount } from "svelte";
  import { mutationStore, gql, getContextClient } from "@urql/svelte";
  import Time from "svelte-time";

  export let authId;
  export let auth;

  let consumer = createConsumer();
  let client = getContextClient();
  let mutation;

  const authorize = (vars) => {
    mutation = mutationStore({
      client,
      query: gql`
        mutation ($input: AuthorizeInput!) {
          authorize(input: $input) {
            requestId
            errorMessage
            errorCode
            avatar
            identifier
            identiconId
            authenticated
            successful
            settled
            loginLink {
              expiresAt
            }
            redirectUri
            prompt
            settings
            warnings
            actor {
              id
              name
              nickname
              identifier
              identifierType
              identiconId
              loginEmail
              loginEmails {
                address
                verifiedAt
                verifyLink
              }
              avatar
              avatarCreatedAt
              passwordChangedAt
              passwordChangeable
            }
            client {
              id
              name
              logo
              allowPasswords
              allowLoginLinks
            }
          }
        }
      `,
      variables: { input: { id: authId, ...vars } },
    });
  };

  let loading = true;
  let identifier;
  let password;
  let updates;

  const startOver = () => {
    auth.identifier = identifier = null;
    auth.password = password = null;
    auth.errorCode = null;
    auth.errorMessage = null;
    auth.prompt = "login";
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

  const updateAuth = (result) => {
    loading = !result || result.fetching;

    if (loading) {
      return;
    }

    auth = result.data?.authorize;
    identifier = auth?.identifier;
    loadingError = result.error;

    if (auth?.settled) {
      setTimeout(() => {
        window.location.assign(auth.redirectUri);
      }, 1000);
    }
  };

  const onUpdate = (v) => {
    if (v != updates) {
      updates = v;
    }
  };

  if (authId) {
    authorize({});
  }

  onMount(() => {
    if (!authId) {
      return;
    }

    return consumer.subscriptions.create(
      { channel: "AuthorizeChannel", id: authId },
      {
        received(data) {
          console.log(data);
        },
      }
    );
  });

  let prompts = {
    identifier: PromptLogin,
    credential: PromptCredential,
    "login-code": PromptLoginCode,
    "login-link": PromptLoginLink,
    "verify-email": PromptVerifyEmail,
    "reset-password": PromptResetPassword,
    authorize: PromptAuthorize,
    onboard: PromptOnboard,
    success: PromptSuccess,
    scopes_required: PromptScopesRequired,
    invalid_request: PromptInvalidRequest,
    invalid_identifier: PromptInvalidIdentifier,
    invalid_redirect_uri: PromptInvalidRedirectUri,
    access_denied: PromptAccessDenied,
    unsupported_response_type: PromptUnsupportedResponseType,
    nonce_required: PromptNonceRequired,
  };

  let loadingError;
  let loadingTimer;

  let computePrompt = (auth, loading, loadingError) => {
    if (loadingError) {
      return PromptLoadingError;
    }

    if (prompts[auth?.prompt]) {
      return prompts[auth.prompt];
    }

    return PromptLoading;
  };

  $: if (!loading && loadingTimer) {
    clearTimeout(loadingTimer);
  }

  $: if (loading) {
    clearTimeout(loadingTimer);

    loadingTimer = setTimeout(() => {
      if (loading) {
        loadingError = true;
      }
    }, 5000);
  }

  let defaultEvent;
  let currentEvent = (name) => {
    defaultEvent = name;
  };

  $: updateAuth($mutation);
</script>

<form
  action="#"
  on:submit={continueAuth({ event: defaultEvent, updates })}
  class="background animate-fade-in flex min-h-full md:p-3 px-[5px] items-center"
>
  <div class="w-full md:w-[502px] mx-auto rounded-2xl shadow-2xl p-[1px]">
    <div
      class="w-full md:w-[500px] mx-auto rounded-2xl overflow-hidden relative shadow-xl"
    >
      <div class="animate-fade-in-slow w-full h-[50px] absolute blur-2xl">
        <div
          class={`rainbow h-full w-full transition-opacity duration-1000 ${loading ? "opacity-15" : "opacity-[.03]"}`}
        />
      </div>
      <div
        class="bg-base-200 animate-fade-in-slow w-full h-[2px] z-10 absolute"
      >
        <div
          class={`rainbow h-full w-full transition-opacity duration-1000 ${loading ? "opacity-15" : "opacity-5"}`}
        />
      </div>
      <div class={`bg-base-300 h-[30px]`}></div>
      <div
        class="bg-base-300 w-full min-h-[200px] md:w-[500px] mx-auto border-b dark:border-base-100 border-white"
      >
        <div class="p-5 md:p-8 pt-0 md:pt-1.5">
          <svelte:component
            this={computePrompt(auth, loading, loadingError)}
            {auth}
            {startOver}
            {authorize}
            {loading}
            {loadingError}
            vars={updates}
            updates={onUpdate}
            setEvent={currentEvent}
            bind:identifier
            bind:password
          />
        </div>
      </div>
    </div>
  </div>
</form>
