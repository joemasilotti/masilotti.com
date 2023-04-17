class UI::Header < SiteComponent
  attr_reader :links, :current_path, :announcements

  def initialize(links:, current_path:, announcements: nil, hide_avatar: false)
    @links, @current_path, @announcements, @hide_avatar =
      links, current_path, announcements, hide_avatar
  end

  def hide_avatar?
    !!@hide_avatar
  end
end
