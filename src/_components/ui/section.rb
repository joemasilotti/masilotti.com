class UI::Section < SiteComponent
  attr_reader :title

  def initialize(title)
    @title = title
  end
end
