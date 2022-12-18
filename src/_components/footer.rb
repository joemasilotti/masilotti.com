class Footer < SiteComponent
  Link = Struct.new(:title, :href)

  attr_reader :newsletter

  def initialize(newsletter:)
    @newsletter = newsletter
  end

  def links
    [
      Link.new("About", "/"),
      Link.new("Services", url_for("_pages/services.erb")),
      Link.new("Projects", url_for("_pages/projects.erb"))
    ]
  end
end
