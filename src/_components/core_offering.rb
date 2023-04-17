class CoreOffering < SiteComponent
  attr_reader :title, :icon, :href, :description, :cta, :badge

  def initialize(title:, icon:, href:, description:, cta:, badge: nil)
    @title, @icon, @href, @description, @cta, @badge =
      title, icon, href, description, cta, badge
  end
end
