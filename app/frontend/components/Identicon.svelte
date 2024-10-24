<script>
  import { minidenticon } from "minidenticons";

  let { id, saturation = 95, lightness = 45, ...others } = $$props;

  let svgURI =
    "data:image/svg+xml;utf8," +
    encodeURIComponent(minidenticon(`@${id}`, saturation, lightness));
</script>

{#key id}
  <img src={svgURI} {...others} />
{/key}
