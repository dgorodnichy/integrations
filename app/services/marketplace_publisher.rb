class MarketplacePublisher
  def self.publish(product)
    product.available_marketplaces.each do |marketplace|
      PublishJob.perform_later(marketplace.to_s, product.id)
    end
  end
end
