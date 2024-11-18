<script>
  import { run, preventDefault, stopPropagation } from "svelte/legacy";

  import _ from "lodash-es";

  import {
    Check,
    Clock,
    Trash2 as Trash,
    MessageSquare,
    Binary,
    QrCode,
    Phone,
    Fingerprint,
    AlertTriangle,
    ChevronDown,
  } from "lucide-svelte";

  import PhoneInput from "./PhoneInput.svelte";
  import CodeInput from "./CodeInput.svelte";
  import Dropdown from "./Dropdown.svelte";
  import Time from "./Time.svelte";
  import Alert from "./Alert.svelte";
  import Card from "./Card.svelte";
  import parsePhoneNumber from "libphonenumber-js";

  let { auth, authorize, authorizing, loading, setLocked } = $props();

  let adding = $state();
  let verifying = $state();
  let phone = $state();
  let code = $state();
  let validPhone = $state();
  let validCode = $state();
  let empty = $derived(!phones?.length);
  let invalid = $state();
  let phones = $state();

  run(() => {
    phones = auth?.actor?.secondFactors?.filter((f) => f.__typename == "Phone");
  });

  run(() => {
    if (phone) {
      invalid = false;
    }
  });

  run(() => {
    if (authorizing) {
      phone = phones[0];
    }
  });

  let addNumber = () => {
    authorize({ event: "phone:send", updates: { phone } }).then((result) => {
      invalid = result?.warnings?.includes("invalid-phone");
      verifying = !invalid;
    });
  };

  let debounceSend = _.debounce(() => {
    let number = phone.number || phone;

    authorize({ event: "phone:send", updates: { phone: number } }).then(() => {
      if (!auth?.warnings?.length) {
        verifying = true;
        setLocked(verifying);
      }
    });
  }, 150);

  let cancelSend = () => {
    verifying = false;
    setLocked(verifying);
  };

  let debounceVerify = _.debounce(() => {
    let number = phone.number || phone;

    authorize({ event: "phone:verify", updates: { phone: number, code } }).then(
      () => {
        if (!auth?.warnings?.length) {
          verifying = false;
          phone = null;
        }
      }
    );
  }, 150);

  run(() => {
    if (validCode && verifying) {
      debounceVerify();
    }
  });

  let formatPhone = (phone) => {
    return parsePhoneNumber(phone?.number)?.formatInternational();
  };
</script>

{#if authorizing}
  <Alert type="primary">
    <Dropdown value={phone}>
      {#snippet summary({ value })}
        <summary
          class="btn btn-xs bg-primary-content text-primary mb-1.5 border-primary-content"
        >
          <span>
            {formatPhone(value)}
          </span>

          {#if verifying}
            <p class="text-xs whitespace-nowrap opacity-75">
              enter the code...
            </p>
          {/if}

          {#if phones?.length > 1}
            <ChevronDown size="16" />
          {/if}
        </summary>
      {/snippet}

      {#snippet dropdown({ setValue, value })}
        <div class="">
          {#if phones?.length > 1}
            <div class="flex flex-col space-y-1.5 my-1.5">
              <div class="text-xs whitespace-nowrap mb-1.5">
                Choose a phone number...
              </div>
              {#each phones as p}
                <button
                  type="button"
                  class={`btn btn-sm whitespace-nowrap ${p == value ? "text-primary" : ""}`}
                  onclick={stopPropagation(
                    preventDefault(setValue(p, (v) => (phone = v)))
                  )}
                >
                  {formatPhone(p)}
                </button>
              {/each}
            </div>
          {:else}
            <span class="whitespace-nowrap opacity-75 text-xs block">
              Phone added <Time timestamp={phone?.createdAt} />
            </span>
          {/if}
        </div>
      {/snippet}
    </Dropdown>

    {#if verifying}
      <div class="">
        <CodeInput
          {auth}
          length={6}
          disabled={loading}
          bind:value={code}
          bind:complete={validCode}
          class="input-lg bg-transparent input-primary placeholder:text-primary placeholder:opacity-25 mb-1.5"
          type="numeric"
        />
      </div>

      <div class="text-center text-sm opacity-75">
        or <button
          class="underline"
          onclick={stopPropagation(preventDefault(cancelSend))}
          type="button">cancel</button
        >
      </div>
    {:else}
      <button
        class="btn btn-primary w-full btn-lg mb-1.5"
        onclick={stopPropagation(preventDefault(debounceSend))}
      >
        <div class="flex items-center gap-3 text-left">
          <MessageSquare size="16" /> send verification code
        </div>
      </button>
    {/if}
  </Alert>
{:else}
  <Card>
    <div class="flex items-center gap-1.5 my-1">
      <MessageSquare size="16" />

      <div class="grow text-xs font-bold">SMS code</div>
    </div>

    {#if empty && !verifying}
      <div class="text-sm opacity-75 mb-3">
        Receive one-time codes to your phone number.
      </div>
    {/if}

    {#if invalid}
      <Alert type="warn" icon={AlertTriangle}>
        {#if validPhone && phone}
          <b>{phone}</b> is already in use...
        {:else}
          Invalid phone number...
        {/if}
      </Alert>
    {/if}

    <div class="flex flex-col gap-1.5">
      {#if !empty}
        {#each phones as phone}
          <div>
            <div class="flex items-center gap-3">
              <PhoneInput disabled value={phone.number}>
                <span
                  class="text-xs whitespace-nowrap text-base-content opacity-75"
                  ><Time ago="old" timestamp={phone.createdAt} /></span
                >

                <button
                  type="button"
                  class="btn btn-xs text-error m-0 p-0 px-1"
                >
                  <Trash size="14" />
                </button>
              </PhoneInput>
            </div>
          </div>
        {/each}
      {/if}

      {#if verifying}
        <div class="bg-base-100 p-3 py-1.5 rounded-lg">
          <p class="text-sm mt-1.5 mb-3 pl-1.5">
            Enter the code that was just sent to <b>{phone}</b>...
          </p>

          <CodeInput
            {auth}
            disabled={loading}
            bind:value={code}
            bind:complete={validCode}
            length={6}
            type="numeric"
          />
        </div>
      {:else if !empty && !adding}
        <button
          type="button"
          class={"btn btn-sm w-full"}
          onclick={stopPropagation(preventDefault(() => (adding = true)))}
        >
          add another phone
        </button>
      {:else}
        <div class="flex items-center gap-3">
          <PhoneInput
            bind:value={phone}
            bind:valid={validPhone}
            selectedCountry={auth?.client?.defaultRegion}
            placeholder={empty
              ? "Add your phone number..."
              : "Add another phone number..."}
          >
            <button
              type="button"
              class={!phone
                ? "hidden"
                : validPhone
                  ? "btn btn-sm btn-success"
                  : "btn btn-sm"}
              disabled={!phone || !validPhone}
              onclick={stopPropagation(preventDefault(addNumber))}
            >
              verify
            </button>
          </PhoneInput>
        </div>
      {/if}
    </div>
  </Card>
{/if}
