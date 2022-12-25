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
    if previewify?
      "https://previewify.app/generate/templates/#{metadata.previewify.template}/meta?url=#{url}"
    else
      absolute_url(resource.data.image || metadata.image)
    end
  end

  def site_name
    metadata.title
  end

  def twitter
    "@#{metadata.twitter}"
  end

  def twitter_card
    "summary_large_image"
  end

  def previewify?
    !!resource.data.previewify
  end

  def previewify_date
    resource.formatted_date
  end

  alias_method :previewify_title, :title

  def previewify_image
    absolute_url("/images/joe.jpg")
  end

  alias_method :previewify_author, :author
  alias_method :previewify_handle, :twitter
end
