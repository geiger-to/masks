<script>
  import { AlertTriangle, X, UserPlus, Save } from "lucide-svelte";
  import { mutationStore, gql, getContextClient } from "@urql/svelte";

  export let search = () => {};
  export let cancel = () => {};

  let result;
  let input = { signup: true };
  let client = getContextClient();
  let errors;
  let loading;

  const addActor = ({ nickname }) => {
    result = mutationStore({
      client,
      query: gql`
        mutation ($input: ActorInput!) {
          actor(input: $input) {
            actor {
              nickname
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

    let data = result?.data?.actor;

    if (!data) {
      return;
    }

    errors = data.errors;

    if (!errors?.length) {
      return search(`@${data.actor.nickname}`);
    }

    loading = false;
  };

  $: handleResult($result);
</script>

<form
  action="#"
  on:submit|preventDefault={() => addActor(input)}
  class="w-full"
>
  <div class="flex items-center join w-full grow">
    <label
      class="input input-bordered flex items-center gap-3 flex-grow
      join-item"
    >
      <UserPlus />

      <input
        type="text"
        class="grow"
        placeholder="enter a nickname for the actor..."
        bind:value={input.nickname}
      />
    </label>

    <div class="join">
      <button
        type="submit"
        class="join-item btn btn-secondary"
        disabled={!input.nickname}><Save size="15" /> save</button
      >
    </div>
  </div>

  {#if errors}
    <div
      class="alert border-2 text-error border-error rounded-lg mt-3 flex
    items-center gap-3"
    >
      <AlertTriangle />
      <ul>
        {#each errors as error}
          <li class="text-sm">{error}</li>
        {/each}
      </ul>
    </div>
  {/if}
</form>
