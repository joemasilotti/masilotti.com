require "faraday"

class OpenGraph::Image
  private attr_reader :resource, :site

  # Example resource_id: repo://posts.collection/_posts/2022-07-22-zero-to-app-store-in-7-weeks.md
  def initialize(resource_id, site: Bridgetown::Site.current)
    @resource = site.resources.find { |r| r.id == resource_id }
    raise "Resource not found!" unless resource.present?
    @site = site
  end

  def download
    json = JSON.parse(create_image)
    image_url = json["data"]["url"]
    download_image(image_url)
  end

  private

  def create_image
    response = Faraday.new(url: base_url).post(path, params.to_json, headers)
    unless response.success?
      raise "Creating image failed: (#{response.status}) #{response.body}"
    end
    response.body
  end

  def download_image(url)
    response = Faraday.get(url, headers:)
    unless response.success?
      raise "Downloading image failed: (#{response.status}) #{response.body}"
    end
    File.binwrite(image_path, response.body)
  end

  def base_url
    "https://previewify.app"
  end

  def path
    "api/v1/sites/#{site_id}/templates/#{template_id}/download"
  end

  def params
    {
      fields: {
        "previewify:date": date,
        "previewify:title": title,
        "previewify:description": description,
        "previewify:image": image.to_s,
        "previewify:author": author,
        "previewify:handle": handle
      }
    }
  end

  def headers
    {
      Accept: "application/json",
      Authorization: "Bearer #{api_key}",
      "Content-Type": "application/json"
    }
  end

  def site_id
    site.config.previewify_site_id
  end

  def template_id
    resource.data.previewify_template
  end

  def date
    resource.data.edition || resource.formatted_date
  end

  def title
    resource.data.previewify_title || resource.data.title
  end

  def description
    resource.data.description
  end

  def image
    URI.join(site.config.url, resource.data.previewify_image)
  end

  def author
    site.metadata.author.name
  end

  def handle
    "@#{site.metadata.author.twitter}"
  end

  def image_path
    File.join("src", "images", "og", "#{resource.relative_url.parameterize}.png")
  end

  def api_key
    ENV["PREVIEWIFY_API_KEY"]
  end
end
