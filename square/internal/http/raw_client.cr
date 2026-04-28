module Square
  module Internal
    module HTTP
      class RawClient
        # Default HTTP status codes that trigger a retry
        RETRYABLE_STATUSES = [408, 429, 500, 502, 503, 504, 521, 522, 524].freeze
        # Initial delay between retries in seconds
        INITIAL_RETRY_DELAY = 0.5
        # Maximum delay between retries in seconds
        MAX_RETRY_DELAY = 60.0
        # Jitter factor for randomizing retry delays (20%)
        JITTER_FACTOR = 0.2
      end
    end
  end
end
