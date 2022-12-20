class UI::Card::Title < SiteComponent
  attr_reader :title, :as, :href

  def initialize(title = nil, as: "h2", href: nil)
    @title, @as, @href = title, as, href
  end
end
