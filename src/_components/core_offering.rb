class CoreOffering < SiteComponent
  attr_reader :title, :icon, :href, :description, :cta

  def initialize(title:, icon:, href:, description:, cta:)
    @title, @icon, @href, @description, @cta =
      title, icon, href, description, cta
  end
end
