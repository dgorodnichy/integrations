class MarketplaceClients::B < MarketplaceClients::Base
  def publish
    return if handler.completed?

    created_product = create_product
    return unless created_product

    publish_product(created_product["inventory_id"])

    handler.completed!
  end

  private

  def create_product
    return cached_step_data("creation", "inventory_id") if step_successful?("creation")

    response = perform_with_retries { post_inventory_to_marketplace }
    handle_response(response, "creation") do |body|
      { "inventory_id" => body["inventory_id"] }
    end
  end

  def publish_product(inventory_id)
    return cached_step_data("publication", "inventory_id") if step_successful?("publication")

    response = perform_with_retries { post_publish_inventory(inventory_id) }
    handle_response(response, "publication")
  end

  def post_inventory_to_marketplace
    Faraday.new(url: 'http://localhost:3002') do |conn|
      conn.headers['Content-Type'] = 'application/json'
    end.post('/inventory', marketplace_params.to_json)
  end

  def post_publish_inventory(inventory_id)
    Faraday.new(url: 'http://localhost:3002') do |conn|
      conn.headers['Content-Type'] = 'application/json'
    end.post("/inventory/#{inventory_id}/publish", {}.to_json)
  end

  def perform_with_retries
    response = nil
    with_retries(max_retries: MAX_RETRIES, retry_delay: RETRY_DELAY) do
      response = yield
      raise ExternalApiError, "Unexpected response status: #{response.status}" unless response.success?
    end
    response
  end

  def step_successful?(step_name)
    return false if handler.steps.blank?
    handler.steps&.fetch(step_name, {})["status"] == "success"
  end

  def cached_step_data(step_name, key)
    handler.steps&.dig(step_name, key)
  end

  def marketplace_params
    {
      "title": product.name,
      "price_cents": product.price,
      "seller_sku": product.sku,
    }
  end
end
