<script>
  import { minidenticon } from "minidenticons";

  let { nickname, saturation = 95, lightness = 45, ...others } = $$props;

  let svgURI =
    "data:image/svg+xml;utf8," +
    encodeURIComponent(minidenticon(`@${nickname}`, saturation, lightness));
</script>

{#key nickname}
  <img src={svgURI} alt={nickname} {...others} />
{/key}
