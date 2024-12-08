require "test_helper"

class MarketplacePublisherTest < ActiveSupport::TestCase
  def setup
    @product = { name: "Product Name", price: 1999, sku: "ABC123" }
    @expected_response = { client_1: { result: "success", id: 1 }, client_2: { result: "success", id: 2 } }
  end

  test "should call publish method for clients" do
    result = MarketplacePublisher.publish(@product, [Client1, Client2])

    assert_equal @expected_response, result
  end
end

class Client1 < MarketplaceClients::Base
  def self.name
    :client_1
  end

  def publish
    { result: "success", id: 1 }
  end
end

class Client2 < MarketplaceClients::Base
  def self.name
    :client_2
  end

  def publish
    { result: "success", id: 2 }
  end
end
