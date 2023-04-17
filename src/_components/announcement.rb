class Announcement < SiteComponent
  delegate :title, :cta, :href, to: :announcement

  def initialize(announcements)
    @announcements = announcements
  end

  def render?
    announcement.present?
  end

  private

  def announcement
    # Set to a key from src/_data/announcements.yml to render an announcement.
    @announcements[""]
  end
end
