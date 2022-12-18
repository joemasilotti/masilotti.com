class Ui::Navigation::Mobile < SiteComponent
  attr_reader :links

  def initialize(links:)
    @links = links
  end
end
