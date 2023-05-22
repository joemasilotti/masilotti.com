class Exclusive < SiteComponent
  attr_reader :title, :description

  def initialize(title:, description:, link: nil)
    @title, @description, @link =
      title, description, link
  end

  def href
    link(@link) if @link.present?
  end
end
