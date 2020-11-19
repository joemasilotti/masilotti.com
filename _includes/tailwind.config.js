const { colors } = require("tailwindcss/defaultTheme");

module.exports = {
  important: "html", // Override typography plugin with more specific selectors.
  purge: [],
  theme: {
    aspectRatio: {
      "16/9": [16, 9]
    },
    extend: {
      colors: {
        primary: colors.green,
      }
    },
    rotate: {
      "-90": "-90deg",
      "-10": "-10deg",
      "0": "0",
      "10": "10deg",
      "90": "90deg",
    },
    typography: theme => ({
      default: {
        css: {
          maxWidth: null,
          img: {
            marginLeft: "auto",
            marginRight: "auto"
          },
          ".highlight": {
            borderRadius: theme("borderRadius.lg")
          },
          ".tldr code": {
            backgroundColor: theme("colors.blue.200"),
            color: theme("colors.blue.900"),
          },
          "pre code": {
            fontSize: theme("fontSize.sm")
          },
          code: {
            backgroundColor: theme("colors.gray.200"),
            paddingTop: theme("spacing.1"),
            paddingRight: theme("spacing.2"),
            paddingBottom: theme("spacing.1"),
            paddingLeft: theme("spacing.2"),
            borderRadius: theme("borderRadius.default")
          },
          "code::before": null,
          "code::after": null,
        }
      }
    })
  },
  variants: {
    rotate: ["group-hover"],
    textColor: ["hover"],
    textDecoration: ["group-hover"],
    underline: ["group-hover"]
  },
  plugins: [
    require("@tailwindcss/typography"),
    require("tailwindcss-responsive-embed"),
    require("tailwindcss-aspect-ratio"),
    require("@tailwindcss/ui"),
  ],
};
