require "test_helper"

class MarketplaceClients::BTest < ActiveSupport::TestCase
  def setup
    MarketplaceClients::B.const_set(:MAX_RETRIES, 3)
    MarketplaceClients::B.const_set(:RETRY_DELAY, 0.1)

    @product = products(:one)
  end

  test "success requests" do
    stub_request(:post, "http://localhost:3002/inventory")
      .with(body: URI.encode_www_form({"price_cents"=>"1999", "seller_sku"=>"ABC1234", "title"=>"Product ABC1234"}))
      .to_return(status: 200, body: { "inventory_id": "12345", "status": "created" }.to_json)

    stub_request(:post, "http://localhost:3002/inventory/12345/publish")
      .to_return(status: 200, body: { "inventory_id": "12345", "status": "published" }.to_json)

    MarketplaceClients::B.publish(@product)

    handler = PublishTaskHandler.find_by(marketplace: "MarketplaceClients::B", product_id: @product.id)

    assert handler.completed?

    assert_equal ({"creation"=>{"code"=>200, "payload"=>"{\"inventory_id\":\"12345\",\"status\":\"created\"}"}, "publication"=>{"code"=>200, "payload"=>"{\"inventory_id\":\"12345\",\"status\":\"published\"}"}}), handler.logs
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

    MarketplaceClients::B.publish(@product)

    handler = PublishTaskHandler.find_by(marketplace: "MarketplaceClients::B", product_id: @product.id)

    assert handler.completed?

    assert_equal ({"creation"=>{"code"=>200, "payload"=>"{\"inventory_id\":\"12345\",\"status\":\"created\"}"}, "publication"=>{"code"=>200, "payload"=>"{\"inventory_id\":\"12345\",\"status\":\"published\"}"}}), handler.logs
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

    MarketplaceClients::B.publish(@product)

    handler = PublishTaskHandler.find_by(marketplace: "MarketplaceClients::B", product_id: @product.id)

    assert handler.completed?
    assert_equal ({"creation"=>{"code"=>200, "payload"=>"{\"inventory_id\":\"12345\",\"status\":\"created\"}"}, "publication"=>{"code"=>200, "payload"=>"{\"inventory_id\":\"12345\",\"status\":\"published\"}"}}), handler.logs
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

    MarketplaceClients::B.publish(@product)

    handler = PublishTaskHandler.find_by(marketplace: "MarketplaceClients::B", product_id: @product.id)

    assert handler.completed?

    assert_equal ({"creation"=>{"code"=>200, "payload"=>"{\"inventory_id\":\"12345\",\"status\":\"created\"}"}, "publication"=>{"code"=>200, "payload"=>"{\"inventory_id\":\"12345\",\"status\":\"published\"}"}}), handler.logs
  end


  test "more than MAX_RETRIES failing attempts" do
    stub_request(:post, "http://localhost:3002/inventory")
      .with(body: URI.encode_www_form("price_cents"=>"1999", "seller_sku"=>"ABC1234", "title"=>"Product ABC1234"))
      .to_return(
        { status: 500, body: { error: 'Internal Server Error' }.to_json },
      )

    result = MarketplaceClients::B.publish(@product)

    handler = PublishTaskHandler.find_by(marketplace: "MarketplaceClients::B", product_id: @product.id)

    assert handler.failed?
    assert_equal ({"creation"=>{"code"=>500, "payload"=>"{\"error\":\"Internal Server Error\"}"}}), handler.logs
  end
end


