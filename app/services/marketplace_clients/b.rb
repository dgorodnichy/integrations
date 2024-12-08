class MarketplaceClients::B < MarketplaceClients::Base
  def self.name
    :b
  end

  def publish
    created_product = create_product
    publish_product(created_product["inventory_id"])
  end

  def create_product
    response = Faraday.new(url: 'http://localhost:3002').post('/inventory', marketplace_params)

    JSON.parse(response.body)
  end

  def publish_product(inventory_id)
    Faraday.new(url: 'http://localhost:3002').post("/inventory/#{inventory_id}/publish", {})
  end

  private

  def marketplace_params
    {
      "title": product.name,
      "price_cents": product.price,
      "seller_sku": product.sku,
    }
  end
end
