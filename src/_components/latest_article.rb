class LatestArticle < SiteComponent
  attr_reader :article

  def initialize(article)
    @article = article
  end
end
