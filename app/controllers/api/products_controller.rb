#  + Add conroller endpoint
#  + Add publisher adaapter
#  + Add marketplace clients
#  + Implement Client test
#  + Client test first step failed
#  + Client test second step failed
#  + Implement clients requests
#  + Return statuses for each step
#  + Impement Retry methods
#  + Implement Logger


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
