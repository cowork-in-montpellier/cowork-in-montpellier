const colors = require("tailwindcss/colors");

module.exports = {
  content: ["./**/*.html"],
  theme: {
    colors: {
      ...colors,
      // transparent: "transparent",
      // current: "currentColor",
      // white: "#ffffff",
      primary: {
        ...colors.primary,
        DEFAULT: "#35a8e0",
      },
    },
    extend: {
      fontFamily: {
        display: ["Playfair Display", "serif"],
        heading: ["Fira Sans Condensed", "serif"],
        sans: ["Overpass", "sans-serif"],
      },
    },
  },
  variants: {},
  plugins: [require("@tailwindcss/typography")],
};
