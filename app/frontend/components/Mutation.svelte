<script>
  import _ from "lodash-es";
  import Error from "./Error.svelte";
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
      if (r?.data && _.get(r.data, key)) {
        props?.onmutate?.(_.get(r.data, key));
        mutating = false;
      }

      if (r?.error) {
        error = r?.error;
        showModal();
      }
    });
  };

  let modal;
  let error = $state();
  let showModal = () => {
    modal.showModal();
  };
</script>

{@render children({ mutating, mutate })}

{#if error}
  <Error {error} />
{/if}
