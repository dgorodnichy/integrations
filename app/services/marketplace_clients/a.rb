class MarketplaceClients::A < MarketplaceClients::Base
  def publish
    return if handler.completed?

    response = perform_with_retries { post_product_to_marketplace }

    handle_response(response, "publication")
  end

  private

  def perform_with_retries
    response = nil
    with_retries(max_retries: MAX_RETRIES, retry_delay: RETRY_DELAY) do
      response = yield
      raise ExternalApiError, "Unexpected response status: #{response.status}" unless response.status == 200
    end

    response
  end

  def post_product_to_marketplace
    Faraday.new(url: 'http://localhost:3001') do |conn|
      conn.headers['Content-Type'] = 'application/json'
    end.post('/api/products', marketplace_params.to_json)
  end

  def marketplace_params
    {
      "name": product.name,
      "price": product.price,
      "sku": product.sku,
    }
  end
end
