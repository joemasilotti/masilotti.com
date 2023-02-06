class WideNewsletter < SiteComponent
  attr_reader :newsletter, :border

  def initialize(newsletter, border: "border-t")
    @newsletter, @border = newsletter, border
  end
end
