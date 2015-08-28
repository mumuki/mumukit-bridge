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
        response = post_to_server(request, 'test')
        response_type = ResponseType.for_response response
        response_type.parse response
      rescue Exception => e
        {result: e.message, status: :errored}
      end

      def run_query!(request)
        response = post_to_server(request, 'query')
        {status: response['exit'].to_sym, result: response['out']}
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
