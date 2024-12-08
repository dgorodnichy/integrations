class MarketplaceClients::A < MarketplaceClients::Base
  def self.name
    :a
  end

  def publish
    with_retries(max_retries: MAX_RETRIES, retry_delay: RETRY_DELAY) do
      response = Faraday.new(url: 'http://localhost:3001').post('/api/products', marketplace_params)

      return response.body if response.success?

      raise ExternalApiError
    end
  end

  private

  def marketplace_params
    {
      "name": product.name,
      "price": product.price,
      "sku": product.sku,
    }
  end
end

