class MarketplacePublisher
  def self.publish(product, clients)
    result = {}
    clients.each do |client|
      result[client.name] = client.publish(product)
    end

    result
  end
end
