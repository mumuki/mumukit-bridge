require 'mumukit/bridge/version'
require 'rest_client'

module Mumukit
  module Bridge
    class Bridge
      attr_accessor :test_runner_url, :structured

      def initialize(test_runner_url)
        @test_runner_url = test_runner_url
        @structured = false
      end

      # Expects a hash
      #  {test: string, extra: string, content: string, expectations: [{binding:string, inspection: string})]}
      # Returns a hash
      #   {result: string, status: string, expectation_results: [{binding:string, inspection:string, result:symbol}], feedback: string}
      def run_tests!(request)
        response = post_to_server(request)

        if !structured
          {result: response['out'],
           status: response['exit'],
           expectation_results: parse_expectation_results(response['expectationResults'] || []),
           feedback: response['feedback'] || ''}
        end
      rescue Exception => e
        {result: e.message, status: :failed}
      end

      def parse_expectation_results(results)
        results.map do |it|
          {binding: it['expectation']['binding'],
           inspection: it['expectation']['inspection'],
           result: it['result'] ? :passed : :failed}
        end
      end

      def post_to_server(request)
        JSON.parse RestClient.post(
                       "#{test_runner_url}/test",
                       request.to_json,
                       content_type: :json)
      end
    end
  end
end
