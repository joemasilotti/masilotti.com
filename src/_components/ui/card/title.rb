class UI::Card::Title < SiteComponent
  attr_reader :as, :href

  def initialize(as: "h2", href: nil)
    @as, @href = as, href
  end
end
