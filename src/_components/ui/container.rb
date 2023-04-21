class UI::Container < SiteComponent
  attr_reader :class_name, :inner_class_name

  def initialize(class_name: nil, inner_class_name: nil)
    @class_name = class_name
    @inner_class_name = inner_class_name
  end
end
