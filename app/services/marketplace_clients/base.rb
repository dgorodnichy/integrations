class MarketplaceClients::Base
  include Retryable

  MAX_RETRIES = 10
  RETRY_DELAY = 2

  attr_reader :product

  def self.publish(product)
    new(product).publish
  end

  def initialize(product)
    @product = product
  end

  def publish
    raise NotImplementedError, "Subclasses must implement the 'publish' method"
  end

  def handler
    ::PublishTaskHandler.find_or_create_by(product_id: product.id, marketplace: self.class.name)
  end


  def handle_response(response, step_name)
    logs = handler.logs || {}
    steps = handler.steps || {}

    logs[step_name] = { code: response.status, payload: response.body }

    if response.success?
      handler.completed!
      steps[step_name] = { "status" => "success" }.merge(block_given? ? yield(JSON.parse(response.body)) : {})
    else
      handler.failed!
      steps[step_name] = { "status" => "fail" }
    end

    handler.update(logs: logs, steps: steps)

    return {} if response.body == ""

    JSON.parse(response.body) if response.success?
  end
end

class ExternalApiError < StandardError; end
