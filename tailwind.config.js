export default {
  content: ["./app/**/*.{svelte,js,css,html.erb}"],
  theme: {
    extend: {},
  },
  plugins: [require("daisyui")],
  daisyui: {
    themes: ["light", "dark", "luxury"],
    logs: false,
  },
};
