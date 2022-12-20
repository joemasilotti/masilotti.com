class Project < SiteComponent
  attr_reader :name, :description, :link, :logo

  def initialize(name:, description:, link:, logo:)
    @name, @description, @link, @logo =
      name, description, link, logo
  end

  def link_options
    external_link? ? {target: "_blank"} : {}
  end

  private

  def external_link?
    !!@link.external
  end
end
