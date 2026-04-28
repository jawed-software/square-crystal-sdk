require "dotenv"

module Square
  class Client
    def initialize(base_url : String? = nil, token : String? = ENV["SQUARE_TOKEN"]?)
    end
  end
end
