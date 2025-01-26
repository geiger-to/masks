import _ from "lodash-es";
import { writable } from "svelte/store";
import { mutationStore, gql, getContextClient } from "@urql/svelte";
import AuthenticateQuery from "./authenticate.graphql?raw";

export const QUERY = gql`
  ${AuthenticateQuery}
`;

export const PROMPTS = [
  "identify",
  "device",
  "credentials",
  "sso",
  "sso-error",
  "sso-accept",
  "sso-link",
  "second-factor",
  "login-code",
  "login-link",
  "verify-email",
  "reset-password",
  "invalid-redirect",
  "missing-scopes",
  "missing-nonce",
  "expired-state",
  "access-denied",
  "authorize",
  "profile",
  "success",
];

export const VERIFIED = {
  "password:change": {
    to: "change your password",
    cta: "change",
    toast: "Password changed",
  },
  "email:create": {
    to: "add ${email}",
    cta: "add",
    toast: "Added ${email}",
  },
  "email:delete": {
    to: "remove ${email}",
    cta: "remove",
    toast: "Removed ${email}",
  },
  "sso:unlink": {
    to: "unlink ${provider}",
    cta: "unlink",
    toast: "Unlinked ${provider}",
  },
  "backup-codes:replace": {
    to: "save your backup codes",
    cta: "save",
    toast: "Backup codes saved",
    if: (p) => p.enabledSecondFactor,
  },
  "webauthn:create": {
    to: "add a security key",
    cta: "add",
    toast: "Security key added",
    if: (p) => p.enabledSecondFactor,
  },
  "webauthn:delete": {
    to: "remove ${webauthn}",
    cta: "remove",
    toast: "Security key removed",
    if: (p) => p.enabledSecondFactor,
  },
  "otp:create": {
    to: "add an authenticator app",
    cta: "add",
    toast: "Authenticator app added",
    if: (p) => p.enabledSecondFactor,
  },
  "otp:delete": {
    to: "remove your authenticator app",
    cta: "remove",
    toast: "Authenticator app deleted",
    if: (p) => p.enabledSecondFactor,
  },
  "phone:create": {
    to: "add your phone number",
    cta: "add",
    toast: "Phone added",
    if: (p) => p.enabledSecondFactor,
  },
  "phone:delete": {
    to: "remove your phone number",
    cta: "remove",
    toast: "Phone removed",
    if: (p) => p.enabledSecondFactor,
  },
};

class Prompt {
  constructor(result, opts) {
    this.graphql = opts?.graphql || getContextClient();
    this.auth = result?.id ? result : result.data.authenticate.entry;
    this.opts = opts || {};
    this.event = opts?.event;
    this.updates = opts?.updates;
    this.extras = this.auth.extras;
    this.warnings = this.auth.warnings;
    this.verifying = opts?.verifying;
    this.loadingError = result.error;
  }

  endSudo() {
    return new Prompt({ ...this.auth }, this.cloneOpts()).noSudo();
  }

  noSudo() {
    this.event = this.opts.event = null;
    this.updates = this.opts.updates = null;
    this.verifying = this.opts.verifying = false;

    return this;
  }

  verification(event, opts) {
    if (!VERIFIED[event]) {
      return;
    }

    return { first: true, second: true, ...VERIFIED[event], ...opts, event };
  }

  refresh(input) {
    this.loading = true;

    if (input.event?.event && !this.verifying) {
      return new Prompt(
        { ...this.auth },
        this.cloneOpts({
          ...input,
          verifying: input.event,
          event: input.event.event,
        })
      );
    }

    return new Promise((res, _) => {
      let variables = {
        input: {
          id: this.auth.id,
          event: input.event,
          updates: input.updates || {},
        },
      };

      if (input.sudo && this.verifying) {
        variables.input.event = this.event;
        variables.input.updates = { ...this.updates, ...input.updates };
      }

      this.mutation = mutationStore({
        client: this.graphql,
        query: QUERY,
        variables,
      });

      this.mutation.subscribe((r) => {
        if (!r || r.fetching) {
          return;
        }

        this.loading = false;

        const result = new Prompt(r, this.cloneOpts());

        if (
          input.sudo &&
          !result.loadingError &&
          !result.warnings?.includes("invalid-factor")
        ) {
          if (result.verifying?.toast && !result.warnings.length) {
            Masks.toast(result.verifying.toast, result.verifying);
          }

          result.verifying?.done?.(result);
          result.noSudo();
        }

        res(result);
      });
    });
  }

  startOver() {
    const prompt = new Prompt(this.auth, this.cloneOpts());

    prompt.auth.actor = null;
    prompt.auth.errorCode = null;
    prompt.auth.errorMessage = null;
    prompt.auth.prompt = "identify";
    prompt.endSudo();

    return prompt;
  }

  cloneOpts(overrides) {
    return { graphql: this.graphql, ...this.opts, ...(overrides || {}) };
  }

  get enabledSecondFactor() {
    return this.validSecondFactor && this.auth?.actor?.secondFactor;
  }

  get validSecondFactor() {
    return (
      this.auth?.actor?.secondFactors?.length &&
      this.auth.actor?.savedBackupCodesAt
    );
  }

  ssoProviders() {
    const list = [];
    const providers = [];

    for (const sso of this.auth?.actor?.singleSignOns || []) {
      list.push(sso);
      providers.push(sso.provider.type);
    }

    for (const provider of this.auth?.providers || []) {
      if (!providers.includes(provider.type)) {
        list.push({ provider });
      }
    }

    return list;
  }
}

export const toasts = writable([]);

export const Masks = {
  prompt: (...args) => new Prompt(...args),
  Prompt,
  toast: (message, vars = null) => {
    const toast = _.template(message)(vars);

    setTimeout(() => {
      toasts.update((v) => v.filter((m) => m !== toast));
    }, 5000);

    toasts.update((v) => [...v, toast]);
  },
};
