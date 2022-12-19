class Article < SiteComponent
  attr_reader :article, :hide_date

  def initialize(article, hide_date: false)
    @article, @hide_date = article, hide_date
  end
end
