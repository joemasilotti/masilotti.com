class Service < SiteComponent
  attr_reader :title, :best_if, :you_get, :description, :href, :cta, :price

  def initialize(title:, best_if:, you_get:, description:, href:, cta:, price: nil)
    @title, @best_if, @you_get, @description, @href, @cta, @price =
      title, best_if, you_get, description, href, cta, price
  end
end
