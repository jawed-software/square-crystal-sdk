module Square
  module Payments
    class Client
      def initialize(@client : Square::Internal::Http::RawClient)
      end

      def list(request_options : Hash(String, String) = {} of String => String, **params) : Square::Internal::CursorItemIterator
        normalized = Square::Internal::Types::Utils.normalize_keys(params.to_h)

        query_params = {} of String => String
        query_params["begin_time"] = normalized["begin_time"].to_s if normalized.has_key?("begin_time")
        query_params["end_time"] = normalized["end_time"].to_s if normalized.has_key?("end_time")
        query_params["sort_order"] = normalized["sort_order"].to_s if normalized.has_key?("sort_order")
        query_params["cursor"] = normalized["cursor"].to_s if normalized.has_key?("cursor")
        query_params["location_id"] = normalized["location_id"].to_s if normalized.has_key?("location_id")
        query_params["total"] = normalized["total"].to_s if normalized.has_key?("total")
        query_params["last_4"] = normalized["last_4"].to_s if normalized.has_key?("last_4")
        query_params["card_brand"] = normalized["card_brand"].to_s if normalized.has_key?("card_brand")
        query_params["limit"] = normalized["limit"].to_s if normalized.has_key?("limit")
        query_params["is_offline_payment"] = normalized["is_offline_payment"].to_s if normalized.has_key?("is_offline_payment")
        query_params["offline_begin_time"] = normalized["offline_begin_time"].to_s if normalized.has_key?("offline_begin_time")
        query_params["offline_end_time"] = normalized["offline_end_time"].to_s if normalized.has_key?("offline_end_time")
        query_params["updated_at_begin_time"] = normalized["updated_at_begin_time"].to_s if normalized.has_key?("updated_at_begin_time")
        query_params["updated_at_end_time"] = normalized["updated_at_end_time"].to_s if normalized.has_key?("updated_at_end_time")
        query_params["sort_field"] = normalized["sort_field"].to_s if normalized.has_key?("sort_field")

        Square::Internal::CursorItemIterator.new(
          cursor_field: "cursor",
          item_field: "payments",
          initial_cursor: query_params["cursor"]?
        ) do |next_cursor|
          query_params["cursor"] = next_cursor if next_cursor
          request = Square::Internal::JSON::Request.new(
            base_url: request_options["base_url"]?,
            method: "GET",
            path: "v2/payments",
            query: query_params,
            request_options: request_options
          )
          begin
            response = @client.send(request)
          rescue IO::TimeoutError
            raise Square::Errors::TimeoutError
          end
          code = response.status.code
          if code >= 200 && code <= 299
            Square::Types::ListPaymentsResponse.load(response.body)
          else
            error_class = Square::Errors::ResponseError.subclass_for_code(code)
            raise error_class.new(response.body, code: code)
          end
        end
      end

      def create(request_options : Hash(String, String) = {} of String => String, **params) : Square::Types::CreatePaymentResponse
        normalized = Square::Internal::Types::Utils.normalize_keys(params.to_h)
        request = Square::Internal::JSON::Request.new(
          base_url: request_options["base_url"]?,
          method: "POST",
          path: "v2/payments",
          body: Square::Payments::Types::CreatePaymentRequest.new(normalized).to_h,
          request_options: request_options
        )
        begin
          response = @client.send(request)
        rescue IO::TimeoutError
          raise Square::Errors::TimeoutError
        end
        code = response.status.code
        if code >= 200 && code <= 299
          Square::Types::CreatePaymentResponse.load(response.body)
        else
          error_class = Square::Errors::ResponseError.subclass_for_code(code)
          raise error_class.new(response.body, code: code)
        end
      end

      def cancel_by_idempotency_key(request_options : Hash(String, String) = {} of String => String, **params) : Square::Types::CancelPaymentByIdempotencyKeyResponse
        normalized = Square::Internal::Types::Utils.normalize_keys(params.to_h)
        request = Square::Internal::JSON::Request.new(
          base_url: request_options["base_url"]?,
          method: "POST",
          path: "v2/payments/cancel",
          body: Square::Payments::Types::CancelPaymentByIdempotencyKeyRequest.new(normalized).to_h,
          request_options: request_options
        )
        begin
          response = @client.send(request)
        rescue IO::TimeoutError
          raise Square::Errors::TimeoutError
        end
        code = response.status.code
        if code >= 200 && code <= 299
          Square::Types::CancelPaymentByIdempotencyKeyResponse.load(response.body)
        else
          error_class = Square::Errors::ResponseError.subclass_for_code(code)
          raise error_class.new(response.body, code: code)
        end
      end

      def get(request_options : Hash(String, String) = {} of String => String, **params) : Square::Types::GetPaymentResponse
        normalized = Square::Internal::Types::Utils.normalize_keys(params.to_h)
        request = Square::Internal::JSON::Request.new(
          base_url: request_options["base_url"]?,
          method: "GET",
          path: "v2/payments/#{normalized["payment_id"]}",
          request_options: request_options
        )
        begin
          response = @client.send(request)
        rescue IO::TimeoutError
          raise Square::Errors::TimeoutError
        end
        code = response.status.code
        if code >= 200 && code <= 299
          Square::Types::GetPaymentResponse.load(response.body)
        else
          error_class = Square::Errors::ResponseError.subclass_for_code(code)
          raise error_class.new(response.body, code: code)
        end
      end

      def update(request_options : Hash(String, String) = {} of String => String, **params) : Square::Types::UpdatePaymentResponse
        normalized = Square::Internal::Types::Utils.normalize_keys(params.to_h)
        request_data = Square::Payments::Types::UpdatePaymentRequest.new(normalized).to_h
        body = request_data.reject { |k, _| k == "payment_id" }

        request = Square::Internal::JSON::Request.new(
          base_url: request_options["base_url"]?,
          method: "PUT",
          path: "v2/payments/#{normalized["payment_id"]}",
          body: body,
          request_options: request_options
        )
        begin
          response = @client.send(request)
        rescue IO::TimeoutError
          raise Square::Errors::TimeoutError
        end
        code = response.status.code
        if code >= 200 && code <= 299
          Square::Types::UpdatePaymentResponse.load(response.body)
        else
          error_class = Square::Errors::ResponseError.subclass_for_code(code)
          raise error_class.new(response.body, code: code)
        end
      end

      def cancel(request_options : Hash(String, String) = {} of String => String, **params) : Square::Types::CancelPaymentResponse
        normalized = Square::Internal::Types::Utils.normalize_keys(params.to_h)
        request = Square::Internal::JSON::Request.new(
          base_url: request_options["base_url"]?,
          method: "POST",
          path: "v2/payments/#{normalized["payment_id"]}/cancel",
          request_options: request_options
        )
        begin
          response = @client.send(request)
        rescue IO::TimeoutError
          raise Square::Errors::TimeoutError
        end
        code = response.status.code
        if code >= 200 && code <= 299
          Square::Types::CancelPaymentResponse.load(response.body)
        else
          error_class = Square::Errors::ResponseError.subclass_for_code(code)
          raise error_class.new(response.body, code: code)
        end
      end

      def complete(request_options : Hash(String, String) = {} of String => String, **params) : Square::Types::CompletePaymentResponse
        normalized = Square::Internal::Types::Utils.normalize_keys(params.to_h)
        request_data = Square::Payments::Types::CompletePaymentRequest.new(normalized).to_h
        body = request_data.reject { |k, _| k == "payment_id" }

        request = Square::Internal::JSON::Request.new(
          base_url: request_options["base_url"]?,
          method: "POST",
          path: "v2/payments/#{normalized["payment_id"]}/complete",
          body: body,
          request_options: request_options
        )
        begin
          response = @client.send(request)
        rescue IO::TimeoutError
          raise Square::Errors::TimeoutError
        end
        code = response.status.code
        if code >= 200 && code <= 299
          Square::Types::CompletePaymentResponse.load(response.body)
        else
          error_class = Square::Errors::ResponseError.subclass_for_code(code)
          raise error_class.new(response.body, code: code)
        end
      end
    end
  end
end
