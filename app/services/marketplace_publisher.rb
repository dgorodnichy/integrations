class MarketplacePublisher
  def self.publish(product, marketplaces)
    marketplaces.each do |marketplace|
      PublishJob.perform_later(marketplace.to_s, product.id)
    end
  end
end
