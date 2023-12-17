module.exports = {
  mode: "jit",
  content: [
    "./app/views/**/*.{slim,erb,jbuilder,turbo_stream,js}",
    "./app/decorators/**/*.rb",
    "./app/helpers/**/*.rb",
    "./app/inputs/**/*.rb",
    "./app/assets/javascripts/**/*.js",
    "./config/initializers/**/*.rb",
    "./lib/components/**/*.rb",
    "./site/**/*.html",
    "./site/**/*.md",
  ],
  safelist: [
    {
      pattern: /bg-(red|green|blue|orange)-(100|200|400)/,
    },
    {
      pattern: /text-(red|green|blue|orange)-(100|200|400)/,
    },
    "pagy-*",
  ],
  variants: {
    extend: {
      overflow: ["hover"],
    },
  },
  theme: {
    listStyleType: {
      none: "none",
      disc: "disc",
      decimal: "decimal",
      square: "square",
    },
    extend: {
      typography(theme) {
        return {
          DEFAULT: {
            css: {
              h1: {
                color: "white",
              },
              h2: {
                color: "#eee",
              },
              h3: {
                color: "#ddd",
              },
              h5: {
                fontWeight: "bold",
                fontSize: "14px",
              },
              figure: {
                borderRadius: "5px",
                margin: "5px 0 0 0",
              },
              summary: {
                fontWeight: "bold",
                fontSize: "15px",
                backgroundColor: "#111",
                borderRadius: "5px",
                padding: "10px 20px",
              },
              code: {
                paddingRight: "1px !important",
                paddingLeft: "1px !important",
              },
              "code::before": {
                content: "none",
              },
              "code::after": {
                content: "none",
              },
            },
          },
        };
      },
    },
  },
  plugins: [require("@tailwindcss/typography"), require("daisyui")],
  daisyui: {
    logs: false,
    themes: [
      "light",
      "dark",
      "cupcake",
      "bumblebee",
      "emerald",
      "corporate",
      "synthwave",
      "retro",
      "cyberpunk",
      "valentine",
      "halloween",
      "garden",
      "forest",
      "aqua",
      "lofi",
      "pastel",
      "fantasy",
      "wireframe",
      "black",
      "luxury",
      "dracula",
      "cmyk",
      "autumn",
      "business",
      "acid",
      "lemonade",
      "night",
      "coffee",
      "winter",
      "dim",
      "nord",
      "sunset",
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
  },
};
