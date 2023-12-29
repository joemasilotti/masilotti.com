require "faraday"
require "json"

class Image
  attr_reader :post, :site

  def initialize(post, site:)
    @post = post
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
    response = Faraday.get(url, headers: headers)
    unless response.success?
      raise "Downloading image failed: (#{response.status}) #{response.body}"
    end
    File.binwrite(image_path, response.body)
  end

  def base_url
    "https://previewlinks.io"
  end

  def path
    "api/v1/sites/#{site_id}/templates/#{template_id}/download"
  end

  def params
    {
      fields: {
        "previewlinks:date": date,
        "previewlinks:title": title,
        "previewlinks:description": description,
        "previewlinks:author": author,
        "previewlinks:handle": handle
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
    site.config["preview_links"]["site_id"]
  end

  def template_id
    post.data["preview_links_template_id"]
  end

  def date
    post.data["edition"] || post.date.strftime("%Y-%m-%d")
  end

  def title
    post.data["og_title"] || post.data["title"]
  end

  def description
    post.data["og_description"] || post.data["description"]
  end

  def author
    site.config["author"]["name"]
  end

  def handle
    "@#{site.config["author"]["twitter"]}"
  end

  def image_path
    File.join(site.source, "assets", "images", "og", "#{post.id}.png")
  end

  def api_key
    ENV["PREVIEW_LINKS_API_KEY"]
  end
end
