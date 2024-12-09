class PublishJob < ActiveJob::Base
  queue_as :default

  def perform(marketplace, product_id)
    product = Product.find(product_id)
    marketplace.constantize.publish(product)
  end
end
