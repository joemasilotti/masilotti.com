class UI::Avatar < SiteComponent
  attr_reader :large

  def initialize(large: false)
    @large = large
  end
end
