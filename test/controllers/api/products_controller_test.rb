require "test_helper"

class Api::ProductsControllerTest < ActionDispatch::IntegrationTest
  test "#create should create a product and respond with 200" do
    stub_request(:post, "http://localhost:3001/api/products")
      .with(body: URI.encode_www_form({"name"=>"Product Name", "price"=>"1999", "sku"=>"ABC123"}))
      .to_return(status: 200, body: { "id": "12345", "status": "success" }.to_json)

    stub_request(:post, "http://localhost:3002/inventory")
      .with(body: URI.encode_www_form({"price_cents"=>"1999", "seller_sku"=>"ABC123", "title"=>"Product Name"}))
      .to_return(status: 200, body: { "inventory_id": "12345", "status": "created" }.to_json)

    stub_request(:post, "http://localhost:3002/inventory/12345/publish")
      .to_return(status: 200)

    product_params = {
      product: {
        "name": "Product Name",
        "price": 1999,
        "sku": "ABC123"
      }
    }

    assert_difference("Product.count", 1) do
      post api_products_url, params: product_params
    end

    assert_response :success
  end
end
