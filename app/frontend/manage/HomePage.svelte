<script>
  import { route } from "@mateothegreat/svelte5-router";
  import Page from "./Page.svelte";
  import Time from "@/components/Time.svelte";
  import { queryStore, gql, getContextClient } from "@urql/svelte";
  import ActorList from "./list/Actor.svelte";
  import ClientList from "./list/Client.svelte";
  import DeviceList from "./list/Device.svelte";
  import EmailList from "./list/Email.svelte";
  import PhoneList from "./list/Phone.svelte";

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

  let tab = $state(props?.params?.tab || "actors");
  let table = {
    actors: {
      plural: "Actors",
      singular: "Actor",
      href: "/manage/actors",
      component: ActorList,
    },
    clients: {
      plural: "Clients",
      singular: "Client",
      href: "/manage/clients",
      component: ClientList,
    },
    devices: {
      plural: "Devices",
      singular: "Device",
      href: "/manage/devices",
      component: DeviceList,
    },
    emails: {
      plural: "Emails",
      singular: "Email",
      href: "/manage/emails",
      component: EmailList,
    },
    phones: {
      plural: "Phones",
      singular: "Phone",
      href: "/manage/phones",
      component: PhoneList,
    },
  };
</script>

<Page {...props}>
  <div
    class="flex items-center gap-1.5 overflow-auto mb-3 tabs tabs-boxed
      tabs-xs md:tabs-sm"
  >
    {#each Object.entries(table) as [key, data]}
      {@const count = stats[key]}
      <a
        use:route
        href={data.href}
        disabled={count == 0}
        class={[
          tab == key
            ? "tab-active"
            : count == 0
              ? "tab-disabled"
              : "tab-neutral",
          "text-right flex items-center gap-1.5 tab flex-nowrap whitespace-nowrap",
        ].join(" ")}
      >
        <span class={[count > 0 ? "" : "opacity-75"].join(" ")}>
          <span>{data.plural}</span>
        </span>

        <span
          class={[
            count > 0 ? "" : "opacity-75",
            "badge badge-xs text-[9px] text-right",
          ].join(" ")}
        >
          {count || "–"}
        </span>
      </a>
    {/each}
  </div>

  {#if table[tab]?.component}
    {@const Tab = table[tab].component}

    <Tab />
  {/if}
</Page>
