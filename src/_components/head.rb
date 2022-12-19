class Head < SiteComponent
  attr_reader :resource, :metadata

  def initialize(resource:, metadata:)
    @resource, @metadata = resource, metadata
  end

  def title
    [resource.data.title, metadata.title].compact.join(" | ")
  end

  def description
    resource.data.description.presence || metadata.description
  end

  def author
    metadata.author
  end

  def url
    resource.absolute_url
  end

  def image
    absolute_url(resource.data.image || metadata.image)
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
