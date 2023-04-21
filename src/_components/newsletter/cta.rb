class Newsletter::CTA < SiteComponent
  attr_reader :newsletter, :title, :description

  def initialize(newsletter, title: nil, description: nil)
    @newsletter = newsletter
    @title = title.presence || newsletter.title
    @description = description.presence || newsletter.description
  end
end
