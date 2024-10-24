<script>
  import { AlertTriangle, RotateCcw } from "lucide-svelte";
  import Identicon from "./Identicon.svelte";
  import PasswordInput from "./PasswordInput.svelte";
  import PromptPassword from "./PromptPassword.svelte";
  import PromptLogin from "./PromptLogin.svelte";
  import PromptLoading from "./PromptLoading.svelte";
  import PromptSuccess from "./PromptSuccess.svelte";
  import PromptAccessDenied from "./PromptAccessDenied.svelte";
  import PromptScopesRequired from "./PromptScopesRequired.svelte";
  import PromptInvalidCredentials from "./PromptInvalidCredentials.svelte";
  import PromptInvalidRequest from "./PromptInvalidRequest.svelte";
  import PromptInvalidRedirectUri from "./PromptInvalidRedirectUri.svelte";
  import PromptUnsupportedResponseType from "./PromptUnsupportedResponseType.svelte";
  import PromptNonceRequired from "./PromptNonceRequired.svelte";
  import PromptAuthorize from "./PromptAuthorize.svelte";
  import { onMount } from "svelte";
  import { mutationStore, gql, getContextClient } from "@urql/svelte";
  import Time from "svelte-time";

  export let authId;
  export let auth;

  let client = getContextClient();
  let mutation;

  const authorize = (vars) => {
    mutation = mutationStore({
      client,
      query: gql`
        mutation ($input: AuthorizeInput!) {
          authorize(input: $input) {
            errorMessage
            errorCode
            avatar
            identifier
            identiconId
            authenticated
            successful
            settled
            redirectUri
            prompt
            settings
            client {
              id
              name
              logo
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

  const startOver = () => {
    auth.identifier = identifier = null;
    auth.password = password = null;
    auth.errorCode = null;
    auth.errorMessage = null;
    auth.prompt = "login";
  };

  const continueAuth = (args) => {
    return (event) => {
      event.preventDefault();

      if (!args.identifier) {
        return;
      }

      let approve = event.submitter.dataset.approve;
      let deny = event.submitter.dataset.deny;

      if (approve) {
        args.approve = true;
      }

      if (deny) {
        args.deny = true;
      }

      authorize(args);
    };
  };

  const updateAuth = (result) => {
    loading = !result || result.fetching;

    if (loading) {
      return;
    }

    auth = result.data.authorize;
    identifier = auth?.identifier;

    if (auth?.settled) {
      setTimeout(() => {
        window.location.assign(auth.redirectUri);
      }, 100);
    }
  };

  if (authId) {
    authorize({});
  }

  let prompts = {
    login: PromptLogin,
    password: PromptPassword,
    authorize: PromptAuthorize,
    success: PromptSuccess,
    scopes_required: PromptScopesRequired,
    invalid_request: PromptInvalidRequest,
    invalid_credentials: PromptInvalidCredentials,
    invalid_redirect_uri: PromptInvalidRedirectUri,
    access_denied: PromptAccessDenied,
    unsupported_response_type: PromptUnsupportedResponseType,
    nonce_required: PromptNonceRequired,
  };

  $: updateAuth($mutation);
</script>

<form
  action="#"
  on:submit={continueAuth({ identifier, password })}
  class="flex h-full w-full align-items-center items-center p-3"
>
  <div class="bg-base-300 rounded-xl min-w-full md:min-w-[500px] mx-auto p-10">
    <svelte:component
      this={!auth && loading ? PromptLoading : prompts[auth?.prompt]}
      {auth}
      {startOver}
      {loading}
      bind:identifier
      bind:password
    />
  </div>
</form>
