class UI::Card::Link < SiteComponent
  attr_reader :href, :properties

  def initialize(href, **properties)
    @href, @properties = href, properties
  end
end
