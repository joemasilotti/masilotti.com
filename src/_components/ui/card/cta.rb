class UI::Card::CTA < SiteComponent
  attr_reader :title

  def initialize(title = nil)
    @title = title
  end
end
