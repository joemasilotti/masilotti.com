class Footer < SiteComponent
  attr_reader :links, :newsletter, :hide_newsletter

  def initialize(links:, newsletter:, hide_newsletter: false)
    @links, @newsletter, @hide_newsletter = links, newsletter, hide_newsletter
  end
end
