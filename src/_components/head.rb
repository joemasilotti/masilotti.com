class Head < SiteComponent
  attr_reader :page, :metadata

  def initialize(page:, metadata:)
    @page, @metadata = page, metadata
  end

  def title
    [page.data.title, metadata.title].compact.join(" | ")
  end

  def description
    page.data.description.presence || metadata.description
  end

  def author
    metadata.author
  end

  def url
    page.absolute_url
  end

  def image
    absolute_url(page.data.image || metadata.image)
  end

  def site_name
    metadata.title
  end

  def twitter
    "@#{metadata.twitter}"
  end

  def twitter_card
    # TODO: Always large?
    "summary_large_image"
  end
end
