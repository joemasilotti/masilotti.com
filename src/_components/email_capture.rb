class EmailCapture < SiteComponent
  attr_reader :cta

  def initialize(newsletter = nil, cta: "Subscribe")
    @newsletter, @cta = newsletter, cta
  end

  def newsletter
    @newsletter ||= data.newsletters.hotwire
  end
end
