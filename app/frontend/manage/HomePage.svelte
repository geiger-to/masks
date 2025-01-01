<script>
  import {
    KeySquare,
    LogIn,
    User,
    Handshake,
    MonitorSmartphone,
    Mail,
    Phone,
  } from "lucide-svelte";
  import { route } from "@mateothegreat/svelte5-router";
  import Page from "./Page.svelte";
  import Time from "@/components/Time.svelte";
  import { queryStore, gql, getContextClient } from "@urql/svelte";
  import ActorList from "./list/Actor.svelte";
  import ClientList from "./list/Client.svelte";
  import DeviceList from "./list/Device.svelte";
  import EntryList from "./list/Entry.svelte";
  import TokenList from "./list/Token.svelte";

  let props = $props();
  let query = $derived(
    queryStore({
      client: getContextClient(),
      query: gql`
        query {
          install {
            stats
          }
        }
      `,
      requestPolicy: "network-only",
    })
  );

  let stats = $state({});
  let data = $state({});
  let subscribe = () => {
    query.subscribe((r) => {
      data = r?.data?.install || {};
      stats = r?.data?.install?.stats || {};
    });
  };

  subscribe();

  let changeTab = (key) => {
    return (e) => {
      e.preventDefault();
      e.stopPropagation();

      tab = key;
    };
  };

  let tab = $state(props?.params?.tab || "entries");
  let table = {
    entries: {
      plural: "Entries",
      singular: "Entry",
      href: "/manage/entries",
      component: EntryList,
      icon: LogIn,
    },
    actors: {
      plural: "Actors",
      singular: "Actor",
      href: "/manage/actors",
      component: ActorList,
      icon: User,
    },
    clients: {
      plural: "Clients",
      singular: "Client",
      href: "/manage/clients",
      component: ClientList,
      icon: Handshake,
    },
    devices: {
      plural: "Devices",
      singular: "Device",
      href: "/manage/devices",
      component: DeviceList,
      icon: MonitorSmartphone,
    },
    tokens: {
      plural: "Tokens",
      singular: "Token",
      href: "/manage/tokens",
      component: TokenList,
      icon: KeySquare,
    },
  };
</script>

<Page {...props}>
  <div class="w-full overflow-hidden">
    <div class="flex">
      <div
        class="flex flex-col gap-1.5 rounded-r rounded-l-box bg-base-100 pl-1.5 py-1.5"
      >
        {#each Object.entries(table) as [key, data]}
          {@const count = stats[key]}
          {@const Icon = data.icon}
          <a
            onclick={changeTab(key)}
            href={data.href}
            disabled={count == 0 || tab == key}
            class={[
              tab == key ? "btn-neutral" : count == 0 ? "btn-disabled" : "",
              "flex items-center justify-start gap-1.5 flex-nowrap whitespace-nowrap btn btn-sm",
              "rounded-r-none px-1.5 pr-2.5",
            ].join(" ")}
          >
            <div class="w-4 text-center flex flex-col items-end">
              <Icon size="14" />
            </div>
            <span
              class={[
                tab == key ? "badge-info" : "badge-neutral",
                count > 0 ? "" : "opacity-75",
                "badge badge-xs text-[9px] text-center",
              ].join(" ")}
            >
              {count || "–"}
            </span>
          </a>
        {/each}
      </div>

      <div class="grow bg-neutral rounded-l rounded-r-box p-3 overflow-hidden">
        {#if table[tab]?.component}
          {@const Tab = table[tab].component}

          <Tab />
        {/if}
      </div>
    </div>
  </div>
</Page>
