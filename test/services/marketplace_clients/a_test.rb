require "test_helper"

class MarketplaceClients::ATest < ActiveSupport::TestCase
  def setup
    MarketplaceClients::A.const_set(:MAX_RETRIES, 5)
    MarketplaceClients::A.const_set(:RETRY_DELAY, 0.1)
  end

  test "success request" do
    stub_request(:post, "http://localhost:3001/api/products")
      .with(body: URI.encode_www_form({"name"=>"Product ABC1234", "price"=>"1999", "sku"=>"ABC1234"}))
      .to_return(status: 200, body: { "id": "12345", "status": "success" }.to_json)

    result = MarketplaceClients::A.publish(products(:one))

    assert_equal ({
      "id": "12345",
      "status": "success"
    }.to_json), result
  end

  test "failed first request" do
    stub_request(:post, "http://localhost:3001/api/products")
      .with(body: URI.encode_www_form({"name"=>"Product ABC1234", "price"=>"1999", "sku"=>"ABC1234"}))
      .to_return(
        { status: 500, body: { error: 'Internal Server Error' }.to_json },
        { status: 200, body: { "id": "12345", "status": "success" }.to_json }
      )

    result = MarketplaceClients::A.publish(products(:one))

    assert_equal ({
      "id": "12345",
      "status": "success"
    }.to_json), result
  end
end

