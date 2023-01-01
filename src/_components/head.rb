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
    if cached_previewify_image?
      URI.join(site.config.url, "images/og/#{resource.relative_url.parameterize}.png").to_s
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

  def cached_previewify_image?
    !!resource.data.cached_previewify_image
  end

  def site_id
    site.config.fathom_site_id
  end
end
