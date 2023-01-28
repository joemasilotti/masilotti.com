class UI::Avatar < SiteComponent
  def initialize(large: false)
    @large = large
  end

  def large?
    !!@large
  end
end
