<script>
  import { copy } from "svelte-copy";
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

  let { key, input, query, children, ...props } = $props();

  let mutating = $state();
  let client = getContextClient();
  let mutate = (vars) => {
    let extras = vars.preventDefault && vars.stopPropagation ? {} : vars;
    let variables = {
      input: { ...input, ...extras },
    };

    if (props.confirm && !confirm(props.confirm)) {
      return;
    }

    mutating = true;

    let update = mutationStore({
      client,
      query,
      variables,
    });

    update.subscribe((r) => {
      if (r?.data && r.data[key]) {
        props?.onmutate?.(r);
        mutating = false;
      }

      if (r?.error) {
        window.location.reload();
      }
    });
  };
</script>

{@render children({ mutating, mutate })}
