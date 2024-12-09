class Api::ProductsController < ApplicationController
  def create
    @product = Product.create(product_params)
    MarketplacePublisher.publish(@product, available_marketplaces)

    render json: @product, status: :ok
  end

  private

  def available_marketplaces
    [
      ::MarketplaceClients::A,
      ::MarketplaceClients::B,
    ]
  end

  def product_params
    params.require(:product).permit(
      :name,
      :price,
      :sku,
    )
  end
end
