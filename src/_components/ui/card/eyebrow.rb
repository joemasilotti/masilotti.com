class UI::Card::Eyebrow < SiteComponent
  attr_reader :as, :decorate, :class_name, :properties

  def initialize(as: "p", decorate: false, class_name: nil, **properties)
    @as, @decorate, @class_name, @properties = as, decorate, class_name, properties
  end
end
