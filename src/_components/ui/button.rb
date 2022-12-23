class UI::Button < SiteComponent
  attr_reader :title, :href, :icon, :properties

  def initialize(variant = :primary, title: nil, href: nil, icon: nil, class_name: nil, **properties)
    @variant, @title, @href, @icon, @class_name, @properties =
      variant, title, href, icon, class_name, properties
  end

  def class_name
    class_map(
      "button" => true,
      variant => true,
      @class_name => true
    )
  end

  private

  def variant
    (@variant == :secondary) ? "button-secondary" : "button-primary"
  end
end
