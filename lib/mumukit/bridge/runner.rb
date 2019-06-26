require_relative './runner/response_type'
require_relative './runner/array'
require_relative './runner/boolean'


module Mumukit
  module Bridge
    class Runner
      attr_accessor :test_runner_url, :timeout, :headers

      def initialize(test_runner_url, timeout=10, headers={})
        @test_runner_url = test_runner_url
        @timeout = timeout
        @headers = headers
      end

      # Expects a hash
      #  {test: string, extra: string, content: string, expectations: [{binding:string, inspection: string})]}
      # Returns a hash
      #   {result: string,
      #    test_results: [{title:string, status:symbol, result:string}],
      #    status: :passed|:failed|:errored|:aborted|:passed_with_warnings,
      #    expectation_results: [{binding:string, inspection:string, result:symbol}],
      #    feedback: string}
      def run_tests!(request, headers={})
        with_server_response 'test', request, headers do |response|
          response_type = ResponseType.for_response response
          response_type.parse response, request
        end
      end

      # Expects a hash
      #  {query: string, extra: string, content: string}
      # Returns a hash
      #   {result: string,
      #    status: :passed|:failed|:errored|:aborted}
      def run_query!(request, headers={})
        with_server_response 'query', request, headers do |it|
          {status: it['exit'].to_sym, result: it['out']}
        end
      end

      def run_try!(request, headers={})
        with_server_response 'try', request, headers do |it|
          {
            status: it['exit'].to_sym,
            result: it['out'],
            query_result: it['queryResult'].try do |it|
              { status: it['status'].to_sym,
                result: it['result'] }
            end
          }
        end
      end

      def assets(path, headers={})
        do_get "assets/#{path}", headers
      end

      def info(headers={})
        JSON.parse do_get(:info, json_content_type(headers))
      end

      private

      def with_server_response(route, request, headers, &action)
        response = do_json_post(route, request, headers)
        action.call(response)
      rescue RestClient::ExceptionWithResponse => e
        {result: "#{e.message}: #{parse_exception_with_response(e)}", status: :aborted}
      rescue Exception => e
        {result: e.message, status: :aborted}
      end

      def do_get(route, headers)
        RestClient.get "#{test_runner_url}/#{route}", build_headers(headers)
      end

      def do_json_post(route, request, headers)
        JSON.parse RestClient::Request.new(
                       method: :post,
                       url: "#{test_runner_url}/#{route}",
                       payload: request.to_json,
                       timeout: @timeout,
                       open_timeout: @timeout,
                       headers: build_headers(json_content_type(headers))).execute
      end

      def get_assets_for(kind, content_type)
        absolutize(get_asset_field(kind, content_type) || [])
      end

      def get_asset_field(kind, field)
        @language_json.dig("#{kind}_assets_urls", field)
      end

      def absolutize(urls)
        urls.map { |url| "#{test_runner_url}/#{url}"}
      end

      def build_headers(headers)
        self.headers.merge(headers)
      end

      def json_content_type(headers)
        headers.merge(content_type: :json)
      end

      def parse_exception_with_response(error)
        (JSON.parse(error.response)['out'] rescue nil) ||
          error.response.presence ||
          "<no reason>"
      end
    end
  end
end
