require 'mumukit/bridge/version'
require 'rest_client'

require 'active_support/hash_with_indifferent_access'
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
      #   {result: string, status: string, expectation_results: [{binding:string, inspection:string, result:symbol}], feedback: string}
      def run_tests!(request)
        response = post_to_server(request)
        parsed_expectation_results = parse_expectation_results(response['expectationResults'] || [])
        parsed_feedback = response['feedback'] || ''

        if structured_test_results? response
          {test_results_type: :structured,
           status: global_status('passed', parsed_expectation_results),
           expectation_results: parsed_expectation_results,
           feedback: parsed_feedback}
        else
          {test_results: response['out'],
           test_results_type: :unstructured,
           status: global_status(response['exit'], parsed_expectation_results),
           expectation_results: parsed_expectation_results,
           feedback: parsed_feedback}
        end
      rescue Exception => e
        {result: e.message, status: :failed}
      end

      def structured_test_results?(response)
        response['testResults'].present?
      end

      def global_status(test_status, expectations_results)
        if test_status == 'passed' && expectations_results.any? { |it| it[:result] == :failed }
          :passed_with_warnings
        else
          test_status.to_sym
        end
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
