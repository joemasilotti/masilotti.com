class Builders::Helpers < SiteBuilder
  def build
    helper :render_snippet do |name|
      site.collections.snippets.resources.find { _1.data.slug == name }.content
    end
  end
end
