require "dotenv"

module Square
  class Client
    def initialize(base_url : String? = nil, token : String? = ENV["SQUARE_TOKEN"]?)
      @raw_client = Square::Internal::Http::RawClient.new(
        base_url: base_url || Square::Environment::PRODUCTION,
        headers: {
          "User-Agent"      => "square.crystal/0.1.0.20260427",
          "X-Fern-Language" => "Crystal",
          "Authorization"   => "Bearer #{token}",
        }
      )
    end
  end
end
