<script>
  import { X, Plus, Save } from "lucide-svelte";
  import { mutationStore, gql, getContextClient } from "@urql/svelte";

  export let search = () => {};
  export let cancel = () => {};

  let result;
  let input = {};
  let client = getContextClient();
  let errors;
  let loading;

  const addClient = ({ name }) => {
    result = mutationStore({
      client,
      query: gql`
        mutation ($input: ClientInput!) {
          client(input: $input) {
            client {
              id
              name
            }

            errors
          }
        }
      `,
      variables: { input },
    });
  };

  const handleResult = (result) => {
    if (!result) {
      return;
    }

    loading = true;
    errors = null;

    if (!result?.data?.client) {
      return;
    }

    let client = result?.data?.client?.client;

    errors = result?.data?.client?.errors;

    if (!errors?.length) {
      return search(client.id);
    }

    loading = false;
  };

  $: handleResult($result);
</script>

<form
  action="#"
  on:submit|preventDefault={() => addClient(input)}
  class="w-full"
>
  <div class="flex items-center w-full grow join">
    <label
      class="input input-bordered flex items-center gap-3 flex-grow
      join-item"
    >
      <Plus />

      <input
        type="text"
        class="grow"
        placeholder="enter a name for the client..."
        bind:value={input.name}
      />
    </label>

    <button
      type="submit"
      class="join-item btn btn-secondary"
      disabled={!input.name}><Save size="15" /> save</button
    >
  </div>
</form>
