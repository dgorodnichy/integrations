class MarketplaceClients::Base
  include Retryable

  MAX_RETRIES = 10
  RETRY_DELAY = 2

  attr_reader :product

  def self.publish(product)
    new(product).publish
  end

  def self.name
    raise NotImplementedError, "Subclasses must implement the 'self.name' method"
  end

  def initialize(product)
    @product = product
  end

  def publish
    raise NotImplementedError, "Subclasses must implement the 'publish' method"
  end
end

class ExternalApiError < StandardError; end
