require "test_helper"

class MarketplacePublisherTest < ActiveSupport::TestCase
  def setup
    @product = products(:one)
  end

  test "should create publish task with completed status" do
    stub_request(:post, "http://localhost:3001/api/products")
      .with(body: {name: "Product ABC1234", price: 1999, sku: "ABC1234"})
      .to_return(status: 200, body: { "id": "12345", "status": "success" }.to_json)

    stub_request(:post, "http://localhost:3002/inventory")
      .with(body: { price_cents: 1999, seller_sku: "ABC1234", title: "Product ABC1234" })
      .to_return(status: 200, body: { inventory_id: "12345", status: "created" }.to_json)

    stub_request(:post, "http://localhost:3002/inventory/12345/publish")
      .to_return(status: 200, body: { inventory_id: "12345", status: "published" }.to_json)

    MarketplacePublisher.publish(@product, [MarketplaceClients::A, MarketplaceClients::B])

    publish_task_a = PublishTaskHandler.find_by(marketplace: "MarketplaceClients::A", product_id: @product.id)
    publish_task_b = PublishTaskHandler.find_by(marketplace: "MarketplaceClients::B", product_id: @product.id)

    assert publish_task_a.completed?
    assert publish_task_b.completed?
  end
end
