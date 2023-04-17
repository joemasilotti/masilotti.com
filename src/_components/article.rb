class Article < SiteComponent
  attr_reader :article, :hide_date, :badge

  def initialize(article, hide_date: false, badge: nil)
    @article, @hide_date, @badge = article, hide_date, badge
  end

  def badge_color
    case badge.to_sym
    when :new
      "pink"
    when :favorite
      "primary"
    end
  end
end
