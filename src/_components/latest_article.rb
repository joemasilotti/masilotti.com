class LatestArticle < SiteComponent
  attr_reader :article

  def initialize(article)
    @article = article
  end

  def new?
    article.date > Date.today - 7
  end
end
