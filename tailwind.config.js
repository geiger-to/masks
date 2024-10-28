export default {
  content: ["./app/**/*.{svelte,js,css,html.erb}"],
  theme: {
    extend: {
      keyframes: {
        denied: {
          "0%": {
            transform: "translateX(0)",
          },
          "6.5%": {
            transform: "translateX(-6px) rotateY(-9deg)",
          },

          "18.5%": {
            transform: "translateX(5px) rotateY(7deg)",
          },

          "31.5%": {
            transform: "translateX(-3px) rotateY(-5deg)",
          },

          "43.5%": {
            transform: "translateX(2px) rotateY(3deg)",
          },
          "50%": {
            transform: "translateX(0)",
          },
        },
      },
      animation: {
        denied: "denied 2s infinite",
      },
    },
    screens: {
      sm: "420px",
      md: "512px",
      lg: "1024px",
      xl: "1280px",
    },
  },
  plugins: [require("daisyui")],
  daisyui: {
    themes: ["light", "dark", "luxury"],
    logs: false,
  },
};
