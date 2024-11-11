<script>
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
  } from "lucide-svelte";

  import PhoneInput from "./PhoneInput.svelte";
  import CodeInput from "./CodeInput.svelte";
  import Time from "./Time.svelte";
  import Alert from "./Alert.svelte";
  import Card from "./Card.svelte";

  export let auth;
  export let authorize;
  export let loading;

  let adding;
  let verifying;
  let phone;
  let code;
  let validPhone;
  let validCode;
  let empty;
  let invalid;

  $: empty = !auth?.actor?.phones?.length;

  $: if (phone) {
    invalid = false;
  }

  let addNumber = () => {
    authorize({ event: "phone:add", updates: { phone } }).then((result) => {
      invalid = result?.warnings?.includes("invalid-phone");
      verifying = !invalid;
    });
  };

  let debounceVerify = _.debounce(() => {
    authorize({ event: "phone:verify", updates: { phone, code } }).then(() => {
      if (!auth?.warnings?.length) {
        verifying = false;
        phone = null;
      }
    });
  }, 150);

  $: if (validCode && verifying) {
    debounceVerify();
  }
</script>

<Card>
  <div class="flex items-center gap-1.5 my-1">
    <MessageSquare size="16" />

    <div class="grow text-xs font-bold">SMS code</div>
  </div>

  {#if empty}
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
    {#if auth?.actor?.phones?.length}
      {#each auth?.actor?.phones || [] as phone}
        <div>
          <div class="flex items-center gap-3">
            <PhoneInput disabled value={phone.number}>
              <span
                class="text-xs whitespace-nowrap text-base-content opacity-75"
                ><Time ago="old" timestamp={phone.createdAt} /></span
              >

              <button type="button" class="btn btn-xs text-error m-0 p-0 px-1">
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
        on:click|preventDefault|stopPropagation={() => (adding = true)}
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
                ? "btn btn-xs btn-success"
                : "btn btn-xs"}
            disabled={!phone || !validPhone}
            on:click|preventDefault|stopPropagation={addNumber}
          >
            verify
          </button>
        </PhoneInput>
      </div>
    {/if}
  </div>
</Card>
