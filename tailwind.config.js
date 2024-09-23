export default {
  content: ["./app/**/*.{svelte,js,css}"],
  theme: {
    extend: {},
  },
  plugins: [require("daisyui")],
  daisyui: {
    themes: ["light", "dark", "luxury"],
  },
};
