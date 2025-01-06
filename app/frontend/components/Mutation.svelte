<script>
  import _ from "lodash-es";
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

<dialog id="my_modal_1" class="modal bg-gray-900" bind:this={modal}>
  <div class="modal-box bg-gray-950 p-10 shadow-2xl">
    <h3 class="text-4xl text-error font-bold mb-6">An error occurred...</h3>
    <p class="text-xl">
      You can ignore the error or <button
        class="underline"
        onclick={() => window.location.reload()}>refresh the page</button
      > to continue.
    </p>
    <div class="block bg-black p-3 font-mono rounded text-green-200 my-3">
      {error}
    </div>
    <div class="modal-action">
      <form method="dialog">
        <button class="btn">Close</button>
      </form>
    </div>
  </div>
</dialog>
