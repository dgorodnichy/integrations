class Api::ProductsController < ApplicationController
  def create
    @product = Product.create(product_params)
    MarketplacePublisher.publish(@product)

    render json: @product, status: :ok
  end

  private

  def product_params
    params.require(:product).permit(
      :name,
      :price,
      :sku,
    )
  end
end
