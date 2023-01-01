class OpenGraph::Images
  private attr_reader :site

  def initialize(site: Bridgetown::Site.current)
    @site = site
  end

  def download
    site.collections.posts.resources.each do |post|
      OpenGraph::Image.new(post.id, site:).download
    end

    site.collections.hotwire.resources.each do |newsletter|
      OpenGraph::Image.new(newsletter.id, site:).download
    end
  end
end
