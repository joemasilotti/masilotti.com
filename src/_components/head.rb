class Head < SiteComponent
  attr_reader :resource, :site

  def initialize(resource:, site:)
    @resource, @site = resource, site
  end

  def title
    [resource.data.title, site.metadata.title].compact.join(" | ")
  end

  def description
    resource.data.description.presence || site.metadata.description
  end

  def author
    site.metadata.author.name
  end

  def url
    resource.absolute_url
  end

  def image
    if previewify?
      "https://previewify.app/generate/templates/#{resource.data.previewify_template}/meta?url=#{url}"
    else
      absolute_url(resource.data.image || site.metadata.image)
    end
  end

  def site_name
    site.metadata.title
  end

  def twitter
    "@#{site.metadata.author.twitter}"
  end

  def twitter_card
    "summary_large_image"
  end

  def previewify?
    !!resource.data.previewify_template.present?
  end

  def previewify_date
    resource.data.edition || resource.formatted_date
  end

  def previewify_title
    resource.data.previewify_title || resource.data.title
  end

  def previewify_image
    absolute_url(resource.data.previewify_image)
  end

  alias_method :previewify_author, :author
  alias_method :previewify_handle, :twitter

  def site_id
    site.config.fathom_site_id
  end
end
