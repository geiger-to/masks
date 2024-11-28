<script>
  import Page from "./Page.svelte";
  import Time from "@/components/Time.svelte";
  import Avatar from "@/components/Avatar.svelte";
  import Identicon from "@/components/Identicon.svelte";
  import EditableImage from "@/components/EditableImage.svelte";
  import { queryStore, gql, getContextClient } from "@urql/svelte";

  let { params, ...props } = $props();
  let client = getContextClient();
  let query = $derived(
    queryStore({
      client: getContextClient(),
      query: gql`
        query ($identifier: String!) {
          actor(identifier: $identifier) {
            id
            name
            nickname
            identifier
            identifierType
            identiconId
            loginEmail
            loginEmails {
              address
              verifiedAt
              verifyLink
            }
            avatar
            avatarCreatedAt
            passwordChangedAt
            passwordChangeable
            secondFactor
            savedBackupCodesAt
            remainingBackupCodes
            secondFactors {
              ... on WebauthnCredential {
                id
                name
                createdAt
                icons {
                  light
                  dark
                }
              }
              ... on Phone {
                number
                createdAt
              }
              ... on OtpSecret {
                id
                name
                createdAt
              }
            }
          }
        }
      `,
      variables: { identifier: params[0] },
      requestPolicy: "network-only",
    })
  );

  let result = $state({ data: {} });
  let actor = $derived(result?.data?.actor);

  query.subscribe((r) => {
    result = r;
  });
</script>

<Page {...props} loading={!actor}>
  <div class="grow flex items-center gap-3">
    <div class="w-12 h-12">
      <EditableImage
        endpoint="/upload/avatar"
        params={{ actor_id: actor.id }}
        src={actor?.avatar}
        name={actor?.identiconId}
        class="w-12 h-12"
      />
    </div>

    <div class="grow mb-1.5">
      <div class="font-bold text-xl flex items-center gap-1.5">
        <span>
          {actor.nickname}
        </span>
      </div>

      <div class="text-xs">
        last login

        <span class="italic">
          {#if actor.lastLoginAt}
            <Time relative timestamp={actor.lastLoginAt} />
          {:else}
            never
          {/if}
        </span>
      </div>
    </div>

    {#if props.actor.identifier == actor.identifier}
      <div class="badge text-xs italic text-info pb-0.5">you</div>
    {/if}

    <div class="w-6 h-6 bg-black p-0.5 rounded">
      <Identicon id={actor.identiconId} />
    </div>
  </div>

  <div class="divider my-1.5" />

  <div class="flex flex-col gap-3 mb-3">
    <span class="text-xs">login email</span>

    {#each actor.loginEmails as email}
      <div class="flex items-center gap-3 text-sm">
        <a href={`mailto:${email.address}`} class="underline font-mono grow">
          {email.address}
        </a>

        {#if email.verifiedAt}
          <Time timestamp={email.verifiedAt} />
        {:else}
          <i class="opacity-75">unverified</i>
        {/if}
      </div>
    {:else}
      <span class="opacity-75 text-xs">nothing found</span>
    {/each}
  </div>

  <div class="divider my-1.5 opacity-75" />

  <div class="flex flex-col gap-3 mb-3">
    <span class="text-xs">phone</span>

    {#each actor.phones as phone}
      <div class="flex items-center gap-3 text-sm">
        <PhoneInput value={phone.number} />
      </div>
    {:else}
      <span class="opacity-75 text-xs">nothing found</span>
    {/each}
  </div>

  <div class="divider my-1.5 opacity-75" />

  <div class="flex flex-col gap-3 mb-3">
    <span class="text-xs">second factor</span>

    {#each actor.secondFactors as factor}
      <div class="flex items-center gap-3 text-sm">
        {JSON.stringify(factor)}
      </div>
    {:else}
      <span class="opacity-75 text-xs">nothing found</span>
    {/each}
  </div>

  <div class="divider my-1.5 opacity-75" />
</Page>
