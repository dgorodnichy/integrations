require "test_helper"

class MarketplaceClients::BTest < ActiveSupport::TestCase
  def setup
    MarketplaceClients::B.const_set(:MAX_RETRIES, 5)
    MarketplaceClients::B.const_set(:RETRY_DELAY, 0.1)
  end

  test "success requests" do
    stub_request(:post, "http://localhost:3002/inventory")
      .with(body: URI.encode_www_form({"price_cents"=>"1999", "seller_sku"=>"ABC1234", "title"=>"Product ABC1234"}))
      .to_return(status: 200, body: { "inventory_id": "12345", "status": "created" }.to_json)

    stub_request(:post, "http://localhost:3002/inventory/12345/publish")
      .to_return(status: 200, body: { "inventory_id": "12345", "status": "published" }.to_json)

    result = MarketplaceClients::B.publish(products(:one))

    assert_equal ({ "inventory_id": "12345", "status": "published" }.to_json), result
  end

  test "failed create step" do
    stub_request(:post, "http://localhost:3002/inventory")
      .with(body: URI.encode_www_form("price_cents"=>"1999", "seller_sku"=>"ABC1234", "title"=>"Product ABC1234"))
      .to_return(
        { status: 500, body: { error: 'Internal Server Error' }.to_json },
        { status: 200, body: { "inventory_id": "12345", "status": "created" }.to_json }
      )

    stub_request(:post, "http://localhost:3002/inventory/12345/publish")
      .to_return(status: 200, body: { "inventory_id": "12345", "status": "published" }.to_json)

    result = MarketplaceClients::B.publish(products(:one))

    assert_equal ({ "inventory_id": "12345", "status": "published" }.to_json), result
  end

  test "failed publish step" do
    stub_request(:post, "http://localhost:3002/inventory")
      .with(body: URI.encode_www_form("price_cents"=>"1999", "seller_sku"=>"ABC1234", "title"=>"Product ABC1234"))
      .to_return(
        status: 200, body: { "inventory_id": "12345", "status": "created" }.to_json
      )

    stub_request(:post, "http://localhost:3002/inventory/12345/publish")
      .to_return(
        { status: 200, body: { "inventory_id": "12345", "status": "published" }.to_json },
        { status: 500, body: { error: 'Internal Server Error' }.to_json },
      )

    result = MarketplaceClients::B.publish(products(:one))

    assert_equal ({ "inventory_id": "12345", "status": "published" }.to_json), result
  end

  test "both steps failed" do
    stub_request(:post, "http://localhost:3002/inventory")
      .with(body: URI.encode_www_form("price_cents"=>"1999", "seller_sku"=>"ABC1234", "title"=>"Product ABC1234"))
      .to_return(
        { status: 500, body: { error: 'Internal Server Error' }.to_json },
        { status: 200, body: { "inventory_id": "12345", "status": "created" }.to_json }
      )

    stub_request(:post, "http://localhost:3002/inventory/12345/publish")
      .to_return(
        { status: 200, body: { "inventory_id": "12345", "status": "published" }.to_json },
        { status: 500, body: { error: 'Internal Server Error' }.to_json },
      )

    result = MarketplaceClients::B.publish(products(:one))

    assert_equal ({ "inventory_id": "12345", "status": "published" }.to_json), result
  end
end


