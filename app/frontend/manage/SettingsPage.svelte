<script>
  import _ from "lodash-es";
  import Page from "./Page.svelte";

  import {
    User,
    Share2,
    Handshake,
    Palette,
    Cog,
    Mail,
    AlertTriangle,
    Database,
    Blocks,
  } from "lucide-svelte";
  import Time from "@/components/Time.svelte";
  import PasswordInput from "@/components/PasswordInput.svelte";
  import SettingClientsTab from "@/manage/SettingClientsTab.svelte";
  import SettingActorsTab from "@/manage/SettingActorsTab.svelte";
  import SettingGeneralTab from "@/manage/SettingGeneralTab.svelte";
  import SettingIntegrationTab from "@/manage/SettingIntegrationTab.svelte";
  import { mutationStore, gql, getContextClient } from "@urql/svelte";

  let props = $props();
  let result = $state();
  let loading = $state(true);
  let errors = $state();
  let install = $state({});
  let client = getContextClient();
  let changes = $state({});
  let original = $state({});
  let changed = $state(false);

  function customizer(objValue, srcValue) {
    if (_.isArray(objValue)) {
      return srcValue;
    }
  }

  let change = (opts) => {
    changes = _.mergeWith(changes, opts, customizer);
    install = _.mergeWith(install, changes, customizer);
    changed = !_.isEqual(original, install);
  };

  let save = () => {
    updateSettings(changes);
  };

  let updateSettings = (input = {}) => {
    result = mutationStore({
      client,
      query: gql`
        mutation ($input: InstallationInput!) {
          install(input: $input) {
            install {
              name
              url
              timezone
              region
              theme
              emails
              needsRestart
              faviconUrl
              lightLogoUrl
              darkLogoUrl
              nicknames
              passwords
              passkeys
              loginLinks
              totpCodes
              phones
              webauthn
              backupCodes
              checks
              clients
              integration
              lifetimes
              needsRestart
              createdAt
              updatedAt
            }
            errors
          }
        }
      `,
      variables: { input },
    });

    result.subscribe((result) => {
      if (!result) {
        return;
      }

      loading = true;
      errors = null;

      if (!result?.data?.install) {
        return;
      }

      let data = result.data.install;

      errors = data.errors;
      original = data.install;
      install = _.cloneDeep(data.install);
      changes = {};
      change({});
      loading = false;
    });
  };

  let tabs = {
    general: {
      name: "General",
      icon: Cog,
      component: SettingGeneralTab,
    },
    client: {
      name: "Client",
      component: SettingClientsTab,
      icon: Handshake,
    },
    actors: {
      name: "Actor",
      component: SettingActorsTab,
      icon: User,
    },
    integration: {
      name: "Integration",
      component: SettingIntegrationTab,
      icon: Blocks,
    },
  };

  let tab = $state(window?.location?.hash.slice(1) || Object.keys(tabs)[0]);
  let Tab = $derived(tabs[tab].component);

  let changeTab = (t) => {
    return (e) => {
      if (loading) {
        return;
      }

      e.preventDefault();
      e.stopPropagation();

      tab = t;
    };
  };

  updateSettings();
</script>

<Page {...props} loading={!install?.createdAt}>
  <div class="flex flex-col gap-3 max-w-prose mx-auto bg-base-200 rounded-lg">
    <div class="flex items-center gap-1.5 px-3 pt-1.5">
      <div class="grow p-1.5">
        <div class="flex items-center gap-1.5 grow">
          <div class="font-bold">{tabs[tab]?.name}</div>
          <div class="opacity-75">settings</div>
        </div>
        <div class="flex items-center gap-1.5">
          {#if install.updatedAt}
            <p class="text-xs opacity-75">
              last saved
              <Time timestamp={install?.updatedAt} />
            </p>
          {/if}
        </div>
      </div>

      {#if install.needsRestart}
        <p class="badge badge-warning badge-sm rounded">restart required</p>
      {/if}

      <button
        class="btn btn-secondary btn-sm"
        onclick={save}
        disabled={!changed}
      >
        save
      </button>
    </div>

    <div>
      <div role="tablist" class="tabs tabs-lifted !px-3">
        {#each Object.keys(tabs) as key}
          {@const Icon = tabs[key].icon}
          <a
            href={`#${key}`}
            onclick={changeTab(key)}
            role="tab"
            class={`${
              loading
                ? "tab tab-disabled"
                : tab == key
                  ? "tab tab-active p-0"
                  : "tab opacity-75 p-0"
            } text-xs truncate`}
          >
            {#if tabs[key].icon}
              <Icon size="14" class="opacity-75 mr-1.5" />
            {/if}

            {#if tabs[key].name}
              <span class="hidden md:inline">
                {tabs[key].name}
              </span>
            {/if}
          </a>
        {/each}
      </div>

      <div class="bg-base-100 p-3 rounded-b-lg rounded-t">
        <div class="p-1.5 flex flex-col gap-3">
          <Tab {...props} {change} settings={install} {errors} {loading} />
        </div>
      </div>
    </div>
  </div>
</Page>
