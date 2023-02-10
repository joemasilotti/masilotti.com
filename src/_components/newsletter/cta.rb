class Newsletter::CTA < SiteComponent
  attr_reader :newsletter

  def initialize(newsletter)
    @newsletter = newsletter
  end
end
