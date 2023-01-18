class UI::Header < SiteComponent
  Link = Struct.new(:title, :href)

  attr_reader :current_path

  def initialize(current_path:)
    @current_path = current_path
  end

  def links
    [
      Link.new("About", "/"),
      Link.new("Articles", url_for("_pages/articles.erb")),
      Link.new("Services", url_for("_pages/services.erb")),
      Link.new("Newsletter", url_for("_pages/hotwire.erb")),
      Link.new("Projects", url_for("_pages/projects.erb")),
      Link.new("Speaking", url_for("_pages/speaking.erb"))
    ]
  end
end
