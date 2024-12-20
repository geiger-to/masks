<script>
  import { goto, query } from "@mateothegreat/svelte5-router";
  import Dropdown from "@/components/Dropdown.svelte";
  import {
    Filter,
    X,
    Search,
    ChevronDown,
    ChevronRight,
    ChevronLeft,
    ChevronUp,
  } from "lucide-svelte";

  let { onchange, ...props } = $props();
</script>

<div class={`flex items-center gap-2 ${props.class}`}>
  <p class="text-neutral-content font-bold text-base grow">
    {props.label || "Records"}
  </p>

  <div class="join">
    <button class="btn btn-xs join-item" disabled>
      <ChevronLeft size="14" />
    </button>

    <button class="btn btn-xs join-item" disabled>
      <ChevronRight size="14" />
    </button>
  </div>
</div>
