class MarketplaceClients::A < MarketplaceClients::Base
  MAX_RETRIES = 10
  RETRY_DELAY = 2

  def self.name
    :a
  end

  def publish
    retries = 0
    begin
      response = Faraday.new(url: 'http://localhost:3001').post('/api/products', marketplace_params)

      if response.status == 200
        return response.body
      else
        raise "Error: #{response.status}" # выбрасываем исключение, если не 200
      end
    rescue => e
      retries += 1
      if retries <= MAX_RETRIES
        puts "Attempt #{retries} failed: #{e.message}. Retrying in #{RETRY_DELAY} seconds..."
        sleep RETRY_DELAY
        retry
      else
        raise "Failed after #{MAX_RETRIES} retries: #{e.message}"
      end
    end
  end

  private


  def marketplace_params
    {
      "name": product.name,
      "price": product.price,
      "sku": product.sku,
    }
  end
end

