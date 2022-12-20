class UI::Navigation::Item < SiteComponent
  attr_reader :title, :href, :current_path

  def initialize(title, href, current_path:)
    @title, @href, @current_path = title, href, current_path
  end

  def active?
    current_path == href
  end
end
