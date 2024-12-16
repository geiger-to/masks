<script>
  import Time from "../components/Time.svelte";
  import Avatar from "../components/Avatar.svelte";
  import { Save, ChevronRight, X } from "lucide-svelte";

  /**
   * @typedef {Object} Props
   * @property {any} actor
   * @property {boolean} [editing]
   * @property {any} [isEditing]
   */

  /** @type {Props} */
  let { actor, editing = false, isEditing = () => {} } = $props();

  let form = { ...actor };
</script>

<a href={`/manage/actor/${actor.id}`}>
  <div class="dark:bg-base-300 bg-base-200 rounded-lg p-3 px-3">
    <div class="flex items-center">
      <div class="grow flex items-center gap-3">
        <div class="w-12 h-12">
          <Avatar {actor} />
        </div>
        <div>
          <div class="font-bold text-lg flex items-center gap-1.5">
            <span>
              {actor.identifier}
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
      </div>
    </div>
  </div>
</a>
