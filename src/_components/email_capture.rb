class EmailCapture < SiteComponent
  attr_reader :newsletter, :cta, :class_name

  def initialize(newsletter, cta: "Subscribe", class_name: nil)
    @newsletter, @cta, @class_name = newsletter, cta, class_name
  end
end
