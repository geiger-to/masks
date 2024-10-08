import daisyui from "daisyui";
import typography from "@tailwindcss/typography";

export default {
  content: [
    "./{css,_docs,_includes,_layouts}/**/*.{css,md,html}",
    "./{index,404}.{md,html}",
  ],
  theme: {
    extend: {},
  },
  plugins: [typography, daisyui],
  daisyui: {
    themes: [
      {
        docs: {
          primary: "gold",
          secondary: "#7c3aed",
          accent: "#c026d3",
          neutral: "#1c1917",
          "base-100": "#000",
          "base-200": "#111",
          "base-300": "#222",
          info: "#22d3ee",
          success: "#22c55e",
          warning: "#eab308",
          error: "#dc2626",
        },
      },
    ],
    logs: false,
  },
};
