<script>
  import Time from "svelte-time";
  import { Image, ImageUp, Save, ChevronDown, X } from "lucide-svelte";
  import { getContext } from "svelte";

  export let endpoint;
  export let src;
  export let name;
  export let params = {};
  export let uploaded = () => {};
  export let disabled;

  let page = getContext("page");

  let uploadFile = (e) => {
    if (!endpoint) {
      return;
    }

    const file = e.target.files[0];
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

<div class="flex items-center cursor-pointer justify-center relative group">
  <label for="file" class={["rounded shadow", $$props.class].join(" ")}>
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
        {#if src}
          <img {src} class="object-cover" />
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
      id="file"
      class="absolute w-full h-full"
      ref="file"
      type="file"
      accept="image/*"
      style="visibility: hidden"
      on:change={uploadFile}
      {disabled}
    />
  </label>
</div>
