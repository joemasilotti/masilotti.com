class UI::Header < SiteComponent
  attr_reader :links, :current_path

  def initialize(links:, current_path:, hide_avatar: false)
    @links, @current_path, @hide_avatar =
      links, current_path, hide_avatar
  end

  def hide_avatar?
    !!@hide_avatar
  end
end
