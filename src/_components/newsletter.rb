class Newsletter < SiteComponent
  attr_reader :newsletter, :title, :description

  def initialize(newsletter, title: nil, description: nil)
    @newsletter = newsletter
    @title = title.presence || newsletter.data.edition || newsletter.data.title
    @description = description.presence || newsletter.data.description
  end
end
