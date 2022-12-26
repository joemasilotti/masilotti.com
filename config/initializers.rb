Bridgetown.configure do |config|
  permalink "pretty"
  template_engine "erb"
  markdown "CustomMarkdownProcessor"

  require "bridgetown-sitemap"
  require "bridgetown-svg-inliner"
  require "bridgetown-view-component"

  hook :loader, :pre_setup do |loader, _|
    loader.inflector.inflect(
      "ui" => "UI",
      "cta" => "CTA"
    )
  end
end
