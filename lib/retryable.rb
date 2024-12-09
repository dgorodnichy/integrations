module Retryable
  def with_retries(max_retries:, retry_delay:)
    retries = 0
    begin
      yield
    rescue => e
      retries += 1
      if retries <= max_retries
        puts "Attempt #{retries} failed: #{e.message}. Retrying in #{retry_delay} seconds..."
        sleep retry_delay
        retry
      end
    end
  end
end
