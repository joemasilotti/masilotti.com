Bridgetown.configure do |config|
  permalink "pretty"
  template_engine "erb"

  init :"bridgetown-svg-inliner"
  init :"bridgetown-view-component"

  hook :loader, :pre_setup do |loader, _|
    loader.inflector.inflect(
      "ui" => "UI",
      "cta" => "CTA"
    )
  end
end
