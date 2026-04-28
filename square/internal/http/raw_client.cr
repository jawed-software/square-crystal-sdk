require "http/client"
require "uri"

module Square
  module Internal
    module Http
      class RawClient
        # Default HTTP status codes that trigger a retry
        RETRYABLE_STATUSES = [408, 429, 500, 502, 503, 504, 521, 522, 524]

        # Initial delay between retries in seconds
        INITIAL_RETRY_DELAY = 0.5

        # Maximum delay between retries in seconds
        MAX_RETRY_DELAY = 60.0

        # Jitter factor for randomizing retry delays (20%)
        JITTER_FACTOR = 0.2

        getter base_url : String
        getter max_retries : Int32
        getter timeout : Float64
        getter default_headers : Hash(String, String)

        def initialize(
          base_url : String,
          max_retries : Int32 = 2,
          timeout : Float64 = 60.0,
          headers : Hash(String, String) = {} of String => String
        )
          @base_url = base_url
          @max_retries = max_retries
          @timeout = timeout
          @default_headers = {
            "X-Fern-Language"    => "Crystal",
            "X-Fern-SDK-Name"    => "square",
            "X-Fern-SDK-Version" => "0.0.1"
          }.merge(headers)
        end

        def send(request) : HTTP::Client::Response
          url = build_url(request)
          attempt = 0

          loop do
            http_request = build_http_request(
              url: url,
              method: request.method,
              headers: request.encode_headers,
              body: request.encode_body
            )

            conn = connect(url)
            response = begin
              conn.exec(http_request)
            ensure
              conn.close
            end

            return response unless should_retry?(response, attempt)

            sleep retry_delay(response, attempt).seconds
            attempt += 1
          end
        end

        def should_retry?(response : HTTP::Client::Response, attempt : Int32) : Bool
          return false if attempt >= @max_retries
          RETRYABLE_STATUSES.includes?(response.status.code)
        end

        def retry_delay(response : HTTP::Client::Response, attempt : Int32) : Float64
          retry_after = response.headers["Retry-After"]?
          if retry_after
            delay = parse_retry_after(retry_after)
            return [delay, MAX_RETRY_DELAY].min if delay && delay > 0
          end

          base_delay = INITIAL_RETRY_DELAY * (2 ** attempt)
          add_jitter([base_delay, MAX_RETRY_DELAY].min)
        end

        def parse_retry_after(value : String) : Float64?
          seconds = value.to_i?
          return seconds.to_f if seconds

          begin
            retry_time = HTTP.parse_time(value)
            if retry_time
              delay = (retry_time - Time.utc).total_seconds
              delay > 0 ? delay : nil
            end
          rescue
            nil
          end
        end

        def add_jitter(delay : Float64) : Float64
          jitter = delay * JITTER_FACTOR * (Random.rand - 0.5) * 2
          [delay + jitter, 0.0].max
        end

        def build_url(request) : URI
          encoded_query = request.encode_query

          if request.path.starts_with?("http://") || request.path.starts_with?("https://")
            url_str = request.path
            if encoded_query && !encoded_query.empty?
              url_str = "#{url_str}?#{encode_query(encoded_query)}"
            end
            return URI.parse(url_str)
          end

          path = request.path.starts_with?("/") ? request.path[1..] : request.path
          base = request.base_url || @base_url
          url_str = "#{base.chomp("/")}/#{path}"
          if encoded_query && !encoded_query.empty?
            url_str = "#{url_str}?#{encode_query(encoded_query)}"
          end
          URI.parse(url_str)
        end

        def build_http_request(
          url : URI,
          method : String,
          headers : Hash(String, String) = {} of String => String,
          body : String? = nil
        ) : HTTP::Request
          resource = url.request_target

          request_headers = HTTP::Headers.new
          @default_headers.merge(headers).each do |name, value|
            request_headers[name] = value
          end

          HTTP::Request.new(method, resource, request_headers, body)
        end

        def encode_query(query : Hash(String, String)) : String
          URI::Params.encode(query)
        end

        def connect(url : URI) : HTTP::Client
          client = HTTP::Client.new(url)
          client.connect_timeout = @timeout.seconds
          client.read_timeout = @timeout.seconds
          client
        end

        def inspect : String
          "#<#{self.class.name}:0x#{object_id.to_s(16)} @base_url=#{@base_url.inspect}>"
        end
      end
    end
  end
end
