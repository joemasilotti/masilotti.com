class Article < SiteComponent
  attr_reader :article, :hide_date

  def initialize(article, hide_date: false, badge: nil)
    @article, @hide_date, @badge = article, hide_date, badge
  end

  def badge
    case @badge&.to_sym
    when :new
      "New"
    when :favorite
      "Favorite"
    end
  end

  def badge_class_names
    case @badge&.to_sym
    when :new
      "bg-pink-100 text-pink-800"
    when :favorite
      "bg-primary-100 text-primary-800"
    end
  end
end
