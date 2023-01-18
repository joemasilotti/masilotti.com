class Appearance < SiteComponent
  attr_reader :title, :description, :event, :cta, :href

  def initialize(title:, description:, event:, cta:, href:)
    @title, @description, @event, @cta, @href =
      title, description, event, cta, href
  end
end
