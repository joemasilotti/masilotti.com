const { colors } = require("tailwindcss/defaultTheme");

module.exports = {
  important: "html", // Override typography plugin with more specific selectors.
  purge: [],
  theme: {
    extend: {
      colors: {
        primary: colors.green
      }
    },
    rotate: {
      "-10": "-10deg",
      "0": "0",
      "10": "10deg"
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
          'pre code': {
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
  ],
};
