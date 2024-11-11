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
  import PromptSecondFactor from "./PromptSecondFactor.svelte";
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
    return new Promise((res, rej) => {
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
              extras
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
                phones {
                  number
                  createdAt
                }
                avatar
                avatarCreatedAt
                passwordChangedAt
                passwordChangeable
                secondFactor
                savedBackupCodesAt
                remainingBackupCodes
                otpSecrets {
                  id
                  name
                  createdAt
                }
                webauthnCredentials {
                  id
                  name
                  createdAt
                }
              }
              client {
                id
                name
                logo
                defaultRegion
                allowPasswords
                allowLoginLinks
              }
            }
          }
        `,
        variables: { input: { id: authId, ...vars } },
      });

      let resolved;

      mutation.subscribe((result) => {
        if (!result?.fetching && !resolved) {
          if (result?.data?.authorize) {
            resolved = true;
            res(result?.data?.authorize);
          }
        }
      });
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

  let prompts = {
    identifier: PromptLogin,
    credential: PromptCredential,
    "login-code": PromptLoginCode,
    "login-link": PromptLoginLink,
    "verify-email": PromptVerifyEmail,
    "reset-password": PromptResetPassword,
    "second-factor": PromptSecondFactor,
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

  let computePrompt = (auth, loading, loadingError) => {
    if (loadingError) {
      return PromptLoadingError;
    }

    if (prompts[auth?.prompt]) {
      return prompts[auth.prompt];
    }

    return PromptLoading;
  };

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
  <div class="w-full md:w-[502px] mx-auto rounded-b-2xl shadow-2xl p-[1px]">
    <div class="w-full md:w-[500px] mx-auto relative rounded-b-2xl shadow-xl">
      <div class={`rounded-t-2xl bg-base-300 h-[30px] overflow-hidden`}>
        <div class="animate-fade-in-slow w-full h-[50px] absolute blur-2xl">
          <div
            class={`rainbow h-full w-full transition-opacity duration-1000 ${loading ? "opacity-15" : "opacity-[.03]"}`}
          />
        </div>
        <div class="bg-base-200 animate-fade-in-slow w-full h-[2px] z-10">
          <div
            class={`rainbow h-full w-full transition-opacity duration-1000 ${loading ? "opacity-15" : "opacity-5"}`}
          />
        </div>
      </div>
      <div class="bg-base-300 w-full min-h-[200px] md:w-[500px] mx-auto">
        <div class="px-5 md:px-8 md:pt-1.5">
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
      <div
        class={`rounded-b-2xl bg-base-300 h-[30px] overflow-hidden border-b dark:border-base-100 border-white overflow-hidden`}
      ></div>
    </div>
  </div>
</form>
