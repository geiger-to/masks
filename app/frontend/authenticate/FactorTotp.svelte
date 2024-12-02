<script>
  import { run, preventDefault, stopPropagation } from "svelte/legacy";

  import _ from "lodash-es";
  import * as OTPAuth from "otpauth";
  import { qr } from "@svelte-put/qr/svg";

  import {
    X,
    Check,
    Clock,
    Trash2 as Trash,
    MessageSquare,
    Binary,
    QrCode as Icon,
    Phone,
    Fingerprint,
    AlertTriangle,
    ChevronDown,
    Info,
  } from "lucide-svelte";

  import Card from "@/components/Card.svelte";
  import PasswordInput from "@/components/PasswordInput.svelte";
  import PhoneInput from "@/components/PhoneInput.svelte";
  import CodeInput from "@/components/CodeInput.svelte";
  import Dropdown from "@/components/Dropdown.svelte";
  import Time from "@/components/Time.svelte";
  import Alert from "@/components/Alert.svelte";

  let { auth, authorize, authorizing, loading } = $props();

  let adding = $state();
  let verifying = $state();
  let showSecret = $state();
  let code = $state();
  let value = $state();
  let empty = $derived(!secrets?.length);
  let secret = $state();
  let secrets = $state();

  let resetOTP = () => {
    adding = false;
    code = [];
    value = null;

    return new OTPAuth.TOTP({
      issuer: auth.settings.name,
      label: auth.actor.identifier,
      secret: new OTPAuth.Secret(),
    });
  };

  let totp = $state(resetOTP());

  run(() => {
    secrets = auth?.actor?.secondFactors?.filter(
      (f) => f.__typename == "OtpSecret"
    );
  });

  run(() => {
    if (authorizing) {
      secret = secrets[0];
    }
  });

  let debounceName = _.debounce((id, name) => {
    authorize({ event: "totp:name", updates: { name, id } });
  }, 500);

  let updateName = (id) => {
    return (e) => {
      debounceName(id, e.target.value);
    };
  };

  let debounceAdd = (secret, inputCode) => {
    if (verifying) {
      return;
    }

    verifying = true;

    return authorize({
      event: "totp:verify",
      updates: { secret, code: inputCode },
    }).then((result) => {
      if (!result?.warnings?.length) {
        totp = resetOTP();
      } else {
        setTimeout(() => (denied = true));
      }

      verifying = false;
    });
  };

  let denied = $state();

  let debounceVerify = _.debounce((secret, inputCode) => {
    if (!secret.id || !inputCode) {
      return;
    }

    authorize({
      event: "totp:verify",
      updates: { id: secret.id, code: inputCode },
    }).then((result) => {
      code = [];
      value = null;

      if (result?.warnings?.length) {
        verifying = false;
        denied = true;
      }
    });
  }, 150);

  run(() => {
    if (code && !verifying) {
      denied = false;
    }
  });

  let dropdown;

  let chooseSecret = (s) => {
    return () => {
      secret = s;

      if (dropdown) {
        dropdown.open = false;
      }
    };
  };
</script>

{#if authorizing}
  <Alert type="primary">
    <div class="flex items-center gap-1.5 mb-1.5">
      <Dropdown value={secret}>
        {#snippet summary()}
          <summary class="flex items-center gap-1.5 btn btn-xs btn-primary">
            <div class="truncate max-w-[175px]">
              {#if secret.name}
                <span class="truncate">{secret.name}</span>
              {:else}
                <span class="truncate opacity-75 italic">unnamed</span>
              {/if}
            </div>

            {#if secrets?.length > 1}
              <ChevronDown size="16" class="opacity-75" />
            {/if}
          </summary>
        {/snippet}

        {#snippet dropdown()}
          <div>
            {#if secrets?.length > 1}
              <ul class="">
                <li class="py-0.5 text-xs opacity-75 whitespace-nowrap pl-1.5">
                  Choose another authenticator...
                </li>
                {#each secrets as s}
                  <li class="py-0.5">
                    <button
                      class={`${s == secret ? "text-primary" : ""} btn btn-xs max-w-[200px] w-auto overflow-hidden`}
                      type="button"
                      onclick={stopPropagation(preventDefault(chooseSecret(s)))}
                    >
                      {#if s.name}
                        <span class="truncate">{s.name}</span>
                      {:else}
                        <span class="truncate opacity-75 italic">unnamed</span>
                      {/if}
                    </button>
                  </li>
                {/each}
              </ul>
            {:else}
              <div class="text-xs whitespace-nowrap flex items-center gap-1.5">
                <Info size="16" />
                <span>
                  You added this authenticator <Time
                    timestamp={secret.createdAt}
                  />.
                </span>
              </div>
            {/if}
          </div>
        {/snippet}
      </Dropdown>

      {#if denied}
        <p class="grow text-right text-xs text-error">
          Invalid code. try again...
        </p>
      {:else}
        <p class="grow text-right text-xs opacity-75 md:block hidden">
          enter the 6-character code
        </p>
      {/if}
    </div>

    <CodeInput
      {auth}
      length={6}
      type="numeric"
      class="input-primary bg-transparent placeholder:text-primary placeholder:opacity-25 input-lg text-xl mb-1.5"
      bind:code
      bind:value
      onComplete={() => debounceVerify(secret, value)}
    />
  </Alert>
{:else}
  <Card>
    <div class="flex items-center gap-1.5 py-1">
      <Icon size="16" />

      <div class="grow">
        <div class="text-xs font-bold">Authenticator app</div>
      </div>
    </div>

    {#if empty && !verifying && !adding}
      <div class="text-sm opacity-75 mb-3">
        Use one-time passwords from an authenticator app.
      </div>
    {/if}

    <div class="flex flex-col gap-1.5 my-1.5">
      {#if secrets?.length}
        {#each secrets as otpSecret}
          <div class="flex items-center gap-3">
            <label
              class="grow flex items-center gap-3 w-full input input-sm px-1.5 h-[35px]"
            >
              <input
                class="w-full pl-1.5 text-base dark:text-white text-black placeholder:text-sm placeholder:text-warning"
                placeholder="Enter a name for this authenticator..."
                value={otpSecret.name}
                oninput={updateName(otpSecret.id)}
                disabled={loading}
              />
              <span
                class="text-xs whitespace-nowrap text-base-content opacity-75"
                ><Time ago="old" timestamp={otpSecret.createdAt} /></span
              >
              <button type="button" class="btn btn-xs text-error m-0 p-0 px-1">
                <Trash size="14" />
              </button>
            </label>
          </div>
        {/each}
      {/if}
    </div>

    {#if adding}
      <div class="mb-3 bg-base-100 p-3 px-4 rounded-lg">
        <div class="flex items-start gap-3 mb-3">
          <p class="text-sm">
            <b>Step one:</b> Scan the following QR code in your authenticator app.
            You can also enter the secret manually:
          </p>

          <button
            type="button"
            onclick={stopPropagation(preventDefault(() => (adding = false)))}
            class="btn btn-sm px-1"><X /></button
          >
        </div>

        <svg
          class="mb-1.5 w-full h-full max-w-[250px] mx-auto rounded"
          use:qr={{
            data: totp.toString(),
            shape: "circle",
          }}
        />

        <!-- QrCode
          text={totp.toString()}
          displayClass="mb-1.5 w-full h-full max-w-[250px] mx-auto rounded"
          width="5"
        /> -->

        <div class="max-w-[250px] mx-auto">
          {#if showSecret}
            <PasswordInput
              disabled
              value={totp.secret.base32}
              class="input-sm ml-0"
            />
          {:else}
            <button
              type="button"
              class="btn btn-link w-full text-center !text-base-content opacity-75 btn-sm"
              onclick={stopPropagation(
                preventDefault(() => (showSecret = true))
              )}>show secret</button
            >
          {/if}
        </div>

        <div class="divider mb-1.5 mt-0"></div>

        <p class="text-sm mb-1.5">
          <b>Step two:</b>
          Enter the 6-digit code generated by your authenticator app:
        </p>

        <CodeInput
          {auth}
          type="numeric"
          length={6}
          bind:code
          bind:value
          onComplete={(e) => debounceAdd(totp.secret.base32, e.detail.value)}
        />
      </div>
    {:else}
      <button
        type="button"
        class="btn btn-sm w-full"
        onclick={stopPropagation(preventDefault(() => (adding = true)))}
      >
        {#if empty}
          add an authenticator
        {:else}
          add another authenticator
        {/if}
      </button>
    {/if}
  </Card>
{/if}
