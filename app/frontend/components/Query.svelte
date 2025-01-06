<script>
  import { copy } from "svelte-copy";
  import _ from "lodash-es";
  import {
    ClipboardX,
    ClipboardCheck,
    ClipboardCopy,
    LogOut,
    RotateCcw,
    MailPlus,
    Trash2 as Trash,
    User,
  } from "lucide-svelte";
  import {
    mutationStore,
    queryStore,
    gql,
    getContextClient,
  } from "@urql/svelte";

  let { key, children, ...props } = $props();

  let loading = $state(true);
  let variables = $state();
  let query = $derived(
    queryStore({
      client: getContextClient(),
      pause: !variables || props.result,
      query: props.query,
      variables,
      requestPolicy: "network-only",
    })
  );

  let result = $state(props.result || []);
  let subscribe = (vars) => {
    if (vars) {
      variables = vars;
    }

    query.subscribe((r) => {
      result = _.get(r?.data || {}, key, []);
      loading = !r?.data;

      if (r?.error) {
        window.location.reload();
      }
    });

    query.resume();
  };

  if (props.variables) {
    subscribe(props.variables);
  }
</script>

{@render children({ result, loading, refresh: subscribe })}
