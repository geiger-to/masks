<script>
  import { minidenticon } from "minidenticons";

  let { id, saturation = 95, lightness = 45, ...others } = $$props;

  let svgURI;

  $: svgURI = id
    ? "data:image/svg+xml;utf8," +
      encodeURIComponent(minidenticon(id, saturation, lightness))
    : null;
</script>

{#if svgURI}
  <img src={svgURI} {...others} />
{/if}
