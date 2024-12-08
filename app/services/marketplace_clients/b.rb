class MarketplaceClients::B < MarketplaceClients::Base
  def self.name
    :b
  end

  def publish
    created_product = create_product
    publish_product(created_product["inventory_id"])
  end

  def create_product
    with_retries(max_retries: MAX_RETRIES, retry_delay: RETRY_DELAY) do
      response = Faraday.new(url: 'http://localhost:3002').post('/inventory', marketplace_params)

      return JSON.parse(response.body) if response.success?

      raise ExternalApiError
    end
  end

  def publish_product(inventory_id)
    with_retries(max_retries: MAX_RETRIES, retry_delay: RETRY_DELAY) do
      response = Faraday.new(url: 'http://localhost:3002').post("/inventory/#{inventory_id}/publish", {})
      return response.body if response.success?

      raise ExternalApiError
    end
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
