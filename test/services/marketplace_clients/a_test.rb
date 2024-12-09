require "test_helper"

class MarketplaceClients::ATest < ActiveSupport::TestCase
  def setup
    MarketplaceClients::A.const_set(:MAX_RETRIES, 3)
    MarketplaceClients::A.const_set(:RETRY_DELAY, 0.1)

    @product = products(:one)
  end

  test "success request" do
    stub_request(:post, "http://localhost:3001/api/products")
      .with(body: {name: "Product ABC1234", price: 1999, sku: "ABC1234"})
      .to_return(status: 200, body: { "id": "12345", "status": "success" }.to_json)

    result = MarketplaceClients::A.publish(@product)

    handler = PublishTaskHandler.find_by(marketplace: "MarketplaceClients::A", product_id: @product.id)

    assert handler.completed?
    assert_equal ({"publication"=>{"code"=>200, "payload"=>"{\"id\":\"12345\",\"status\":\"success\"}"}}), handler.logs
  end

  test "failed first request" do
    stub_request(:post, "http://localhost:3001/api/products")
      .with(body: {name: "Product ABC1234", price: 1999, sku: "ABC1234"})
      .to_return(
        { status: 500, body: { error: 'Internal Server Error' }.to_json },
        { status: 200, body: { "id": "12345", "status": "success" }.to_json }
      )

    result = MarketplaceClients::A.publish(@product)

    handler = PublishTaskHandler.find_by(marketplace: "MarketplaceClients::A", product_id: @product.id)

    assert handler.completed?
    assert_equal ({"publication"=>{"code"=>200, "payload"=>"{\"id\":\"12345\",\"status\":\"success\"}"}}), handler.logs
  end

  test "more than MAX_RETRIES failing attempts" do
    stub_request(:post, "http://localhost:3001/api/products")
      .with(body: {name: "Product ABC1234", price: 1999, sku: "ABC1234"})
      .to_return( status: 500, body: { error: 'Internal Server Error' }.to_json)

    result = MarketplaceClients::A.publish(@product)

    handler = PublishTaskHandler.find_by(marketplace: "MarketplaceClients::A", product_id: @product.id)

    assert handler.failed?
    assert_equal ({"publication"=>{"code"=>500, "payload"=>"{\"error\":\"Internal Server Error\"}"}}), handler.logs
  end
end

