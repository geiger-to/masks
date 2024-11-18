<!-- @migration-task Error while migrating Svelte code: $$props is used together with named props in a way that cannot be automatically migrated. -->
<!-- @migration-task Error while migrating Svelte code: $$props is used together with named props in a way that cannot be automatically migrated. -->
<!-- @migration-task Error while migrating Svelte code: $$props is used together with named props in a way that cannot be automatically migrated. -->
<!-- @migration-task Error while migrating Svelte code: $$props is used together with named props in a way that cannot be automatically migrated. -->
<!-- @migration-task Error while migrating Svelte code: $$props is used together with named props in a way that cannot be automatically migrated. -->
<!-- @migration-task Error while migrating Svelte code: $$props is used together with named props in a way that cannot be automatically migrated. -->
<!-- @migration-task Error while migrating Svelte code: $$props is used together with named props in a way that cannot be automatically migrated. -->
<!-- @migration-task Error while migrating Svelte code: $$props is used together with named props in a way that cannot be automatically migrated. -->
<!-- @migration-task Error while migrating Svelte code: $$props is used together with named props in a way that cannot be automatically migrated. -->
<!-- @migration-task Error while migrating Svelte code: $$props is used together with named props in a way that cannot be automatically migrated. -->
<!-- @migration-task Error while migrating Svelte code: $$props is used together with named props in a way that cannot be automatically migrated. -->
<!-- @migration-task Error while migrating Svelte code: $$props is used together with named props in a way that cannot be automatically migrated. -->
<!-- @migration-task Error while migrating Svelte code: $$props is used together with named props in a way that cannot be automatically migrated. -->
<!-- @migration-task Error while migrating Svelte code: $$props is used together with named props in a way that cannot be automatically migrated. -->
<!-- @migration-task Error while migrating Svelte code: $$props is used together with named props in a way that cannot be automatically migrated. -->
<!-- @migration-task Error while migrating Svelte code: $$props is used together with named props in a way that cannot be automatically migrated. -->
<!-- @migration-task Error while migrating Svelte code: $$props is used together with named props in a way that cannot be automatically migrated. -->
<!-- @migration-task Error while migrating Svelte code: $$props is used together with named props in a way that cannot be automatically migrated. -->
<!-- @migration-task Error while migrating Svelte code: $$props is used together with named props in a way that cannot be automatically migrated. -->
<script>
  import Time from "svelte-time";
  import { Image, ImageUp, Save, ChevronDown, X } from "lucide-svelte";
  import { getContext } from "svelte";

  /**
   * @typedef {Object} Props
   * @property {any} endpoint
   * @property {any} src
   * @property {any} name
   * @property {any} [params]
   * @property {any} [uploaded]
   * @property {boolean} [disabled]
   * @property {any} cls
   * @property {import('svelte').Snippet} [children]
   */

  /** @type {Props} */
  let {
    endpoint,
    src = $bindable(),
    name,
    params = {},
    uploaded = () => {},
    disabled = false,
    class: cls,
    children,
  } = $props();

  let id = crypto.randomUUID();
  let page = getContext("page");
  let uploadedSrc = $state();

  let uploadFile = (e) => {
    const file = e.target.files[0];
    const reader = new FileReader();
    reader.onload = (e) => {
      uploadedSrc = e.target.result;
    };
    reader.readAsDataURL(file);

    if (!endpoint) {
      return uploaded(file);
    }

    const formData = new FormData();

    Object.entries(params).forEach(([k, v]) => formData.append(k, v));

    formData.append("file", file);

    page
      .fetch(endpoint, {
        method: "POST",
        body: formData,
      })
      .then(async (response) => {
        if (response.ok) {
          let json = await response.json();

          src = json.url;

          uploaded(src);
        } else {
          throw new Error("File upload failed");
        }
      });
  };

  let placeholder = name
    ? name
        .split(" ")
        .map((word) => word[0])
        .join("")
        .toUpperCase()
        .slice(0, 2)
    : null;
</script>

<label
  for={id}
  class="flex items-center cursor-pointer justify-center gap-1 group"
>
  <div
    class={[
      "rounded shadow relative",
      disabled ? "" : "cursor-pointer",
      cls,
    ].join(" ")}
  >
    <div
      class={[
        "bg-black text-white z-10 flex items-center justify-center",
        "rounded absolute w-full h-full opacity-0 group-hover:opacity-70",
        disabled ? "hidden" : "",
      ].join(" ")}
    >
      <ImageUp />
    </div>

    <div class="avatar placeholder">
      <div class="bg-neutral text-neutral-content rounded text-center">
        {#if src || uploadedSrc}
          {#key src || uploadedSrc}
            <img src={uploadedSrc || src} class="object-cover" alt="uploaded" />
          {/key}
        {:else}
          <span
            class={[
              "flex items-center justify-center text-xl opacity-70",
              cls,
            ].join(" ")}
          >
            {#if disabled}
              <Image />
            {:else}
              <ImageUp />
            {/if}
          </span>
        {/if}
      </div>
    </div>

    <input
      {id}
      class="absolute w-full h-full"
      ref="file"
      type="file"
      accept="image/*"
      style="visibility: hidden"
      onchange={uploadFile}
      {disabled}
    />
  </div>

  {@render children?.()}
</label>
