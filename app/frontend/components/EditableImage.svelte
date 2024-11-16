<script>
  import Time from "svelte-time";
  import { Image, ImageUp, Save, ChevronDown, X } from "lucide-svelte";
  import { getContext } from "svelte";

  export let endpoint;
  export let src;
  export let name;
  export let params = {};
  export let uploaded = () => {};
  export let disabled = false;

  let id = crypto.randomUUID();
  let page = getContext("page");
  let uploadedSrc;

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
      $$props.class,
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
              $$props.class,
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
      on:change={uploadFile}
      {disabled}
    />
  </div>

  <slot />
</label>
