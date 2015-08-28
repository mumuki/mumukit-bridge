require 'mumukit/bridge/version'
require 'mumukit/bridge/response_type'
require 'mumukit/bridge/array'
require 'mumukit/bridge/boolean'

require 'rest_client'

require 'active_support/core_ext/object'

module Mumukit
  module Bridge
    class Bridge
      attr_accessor :test_runner_url

      def initialize(test_runner_url)
        @test_runner_url = test_runner_url
      end

      # Expects a hash
      #  {test: string, extra: string, content: string, expectations: [{binding:string, inspection: string})]}
      # Returns a hash
      #   {result: string,
      #    test_results: [{title:string, status:symbol, result:string}],
      #    status: :passed|:failed|:errored|:aborted|:passed_with_warnings,
      #    expectation_results: [{binding:string, inspection:string, result:symbol}],
      #    feedback: string}
      def run_tests!(request)
        with_sever_response request, 'test' do |response|
          response_type = ResponseType.for_response response
          response_type.parse response
        end
      end

      def run_query!(request)
        with_sever_response request, 'query' do | it |
          {status: it['exit'].to_sym, result: it['out']}
        end
      end

      def with_sever_response(request, route, &action)
        response = post_to_server(request, route)
        action.call(response)
      rescue Exception => e
        {result: e.message, status: :errored}
      end

      def post_to_server(request, route)
        JSON.parse RestClient.post(
                       "#{test_runner_url}/#{route}",
                       request.to_json,
                       content_type: :json)
      end
    end
  end
end
