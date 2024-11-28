<script>
  import { run } from "svelte/legacy";

  import { mutationStore, gql, getContextClient } from "@urql/svelte";
  import { Mail, AlertTriangle } from "lucide-svelte";
  import PasswordInput from "@/components/PasswordInput.svelte";

  let result = $state();
  let loading = $state(true);
  let errors;
  let settings = $state();
  let client = getContextClient();

  const updateSettings = (settings) => {
    result = mutationStore({
      client,
      query: gql`
        mutation ($input: SettingInput!) {
          setting(input: $input) {
            settings
            errors
          }
        }
      `,
      variables: { input: { settings } },
    });
  };

  const handleResult = (result) => {
    if (!result) {
      return;
    }

    loading = true;
    errors = null;

    if (!result?.data?.setting) {
      return;
    }

    let data = result.data.setting;

    errors = data.errors;
    settings = data.settings;
    loading = false;
  };

  updateSettings();

  run(() => {
    handleResult($result);
  });
</script>

<div class="flex flex-col gap-3 mb-3 max-w-prose mx-auto">
  {#if !loading}
    <div class="flex items-center gap-3 mb-3">
      <Mail />
      <h3 class="font-bold grow">email</h3>

      <button class="btn btn-sm btn-success">save</button>
    </div>

    <label class="label cursor-pointer bg-base-200 rounded-lg px-4 pt-2 pb-3">
      <div class="flex flex-col gap-1">
        <span class="label-text">email addresses</span>
        <span class="label-text-alt">
          allow actors to add and login with their email(s)
        </span>
      </div>
      <input
        type="checkbox"
        class="toggle"
        bind:checked={settings.email.addresses}
      />
    </label>

    <label
      class="label cursor-pointer bg-base-200 rounded-lg px-4 pt-2 pb-3 hidden TODO"
    >
      <div class="flex flex-col gap-1">
        <span class="label-text">password recovery</span>
        <span class="label-text-alt">
          allow changing passwords with a verified email
        </span>
      </div>
      <input type="checkbox" class="toggle" disabled />
    </label>

    <label
      class="label cursor-pointer bg-base-200 rounded-lg px-4 pt-2 pb-3 hidden TODO"
    >
      <div class="flex flex-col gap-1">
        <span class="label-text">magic links</span>
        <span class="label-text-alt">
          allow login via "magic links" sent to verified emails
        </span>
      </div>
      <input type="checkbox" class="toggle" disabled />
    </label>

    <h3 class="font-bold text-sm mt-6">smtp details</h3>

    <label class="input input-bordered flex items-center gap-3">
      <span class="label-text opacity-70 w-[60px]">address</span>
      <input
        type="text"
        class="grow ml-3"
        placeholder="e.g. smtp.example.com..."
        bind:value={settings.email.smtp.address}
      />
    </label>
    <label class="input input-bordered flex items-center gap-3">
      <span class="label-text opacity-70 w-[60px]">port</span>
      <input
        type="text"
        class="grow ml-3"
        placeholder="e.g. 25, 465 or 587..."
        bind:value={settings.email.smtp.port}
      />
    </label>
    <label class="input input-bordered flex items-center gap-3">
      <span class="label-text opacity-70 w-[60px]">username</span>
      <input
        type="text"
        class="grow ml-3"
        placeholder="..."
        bind:value={settings.email.smtp.username}
      />
    </label>
    <PasswordInput
      label="password"
      placeholder="..."
      bind:value={settings.email.smtp.password}
    />
  {/if}
</div>
