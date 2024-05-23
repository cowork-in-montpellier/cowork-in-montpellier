const colors = require("tailwindcss/colors");

module.exports = {
  content: ["./**/*.html", "./**/*.njk"],
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
        display: ["Museo", "Playfair Display", "serif"],
        heading: ["Fira Sans Condensed", "serif"],
        sans: ["Overpass", "sans-serif"],
      },
    },
  },
  variants: {},
  plugins: [require("@tailwindcss/typography")],
};
