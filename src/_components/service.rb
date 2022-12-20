class Service < SiteComponent
  attr_reader :title, :price, :best_if, :you_get, :description, :href

  def initialize(title:, price:, best_if:, you_get:, description:, href:)
    @title, @price, @best_if, @you_get, @description, @href =
      title, price, best_if, you_get, description, href
  end
end
