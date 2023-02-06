class Footer < SiteComponent
  attr_reader :links, :newsletter

  def initialize(links:, newsletter:)
    @links, @newsletter = links, newsletter
  end
end
