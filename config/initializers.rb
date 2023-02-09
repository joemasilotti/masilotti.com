Bridgetown.configure do |config|
  permalink "pretty"
  template_engine "erb"
  markdown "CustomMarkdownProcessor"

  init :"bridgetown-svg-inliner"
  init :"bridgetown-view-component"
  init :dotenv

  unless Bridgetown.env.development?
    init :"bridgetown-feed"
    init :"bridgetown-sitemap"
  end

  hook :loader, :pre_setup do |loader, _|
    loader.inflector.inflect(
      "ui" => "UI",
      "cta" => "CTA"
    )
  end
end
