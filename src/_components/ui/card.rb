class UI::Card < SiteComponent
  attr_reader :as, :class_name

  def initialize(as: :div, class_name: nil)
    @as, @class_name = as, class_name
  end
end
