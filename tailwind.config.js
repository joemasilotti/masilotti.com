const colors = require("tailwindcss/colors")

module.exports = {
  content: [
    "./_drafts/**/*.md",
    "./_includes/**/*.{html,liquid}",
    "./_layouts/**/*.{html,liquid}",
    "./_pages/*.{html,liquid}",
    "./_posts/*.md",
    "./*.md",
    "./*.html"
  ],
  theme: {
    extend: {
      colors: {
        primary: colors.emerald,
        gray: colors.zinc,
      },
      typography: (theme) => ({
        DEFAULT: {
          css: {
            // Hide quotation marks before block quotes.
            "blockquote p:first-of-type::before": false,
            // Hide quotation marks after block quotes.
            "blockquote p:first-of-type::after": false,
            // Remove italics and medium font weight from block quotes.
            blockquote: {
              color: theme("colors.gray.500"),
              fontStyle: "normal",
              fontWeight: "normal"
            },
            // Emphasize <strong> tags more in block quotes.
            "blockquote strong": {
              color: theme("colors.gray.600")
            },
            // Hide backtick before inline code blocks.
            "code::before": {
              content: "hidden"
            },
            // Hide backtick after inline code blocks.
            "code::after": {
              content: "hidden"
            },
            // Rounded gray background around inline code blocks.
            code: {
              backgroundColor: theme("colors.gray.100"),
              borderRadius: theme("borderRadius.DEFAULT"),
              paddingLeft: theme("spacing.2"),
              paddingRight: theme("spacing.2"),
              paddingTop: theme("spacing.1"),
              paddingBottom: theme("spacing.1")
            },
            // Opt-out of rounded <img> corners and shadow with {:standalone .unstyled}.
            "figure.unstyled img": {
              borderRadius: 0,
              boxShadow: "none"
            },
            // Round <img> corners and add shadow with {:standalone}.
            img: {
              borderRadius: theme("borderRadius.lg"),
              boxShadow: theme("boxShadow.DEFAULT")
            }
          }
        }
      })
    }
  },
  plugins: [
    require("@tailwindcss/forms"),
    require("@tailwindcss/typography")
  ]
}
