namespace :marketplace do
  desc "Publish a product to the marketplaces by SKU"
  task publish: :environment do
    sku = ENV['sku']

    if sku.nil? || sku.strip.empty?
      puts "Error: Please provide a SKU as an argument. Example: rake marketplace:publish sku=ABC123"
      exit(1)
    end

    product = Product.find_by(sku: sku)

    if product.nil?
      puts "Error: Product with SKU '#{sku}' not found."
      exit(1)
    end

    begin
      MarketplacePublisher.publish(product)
      puts "Product '#{product.name}' (SKU: #{sku}) successfully published."
    rescue => e
      puts "Error: Failed to publish product. Reason: #{e.message}"
      exit(1)
    end
  end
end
