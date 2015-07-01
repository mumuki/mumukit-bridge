module Mumukit::Bridge

  class ResponseParser
    def self.parse(response)
      parsed_expectation_results = parse_expectation_results(response['expectationResults'] || [])
      parsed_feedback = response['feedback'] || ''

      if structured_test_results? response
        test_results = response.slice('testResults').deep_symbolize_keys
        {test_results_type: :structured,
         test_results: test_results,
         status: global_status(
             test_results[:testResults].any? { |it| it[:status] == 'failed' } ? :failed : :passed, parsed_expectation_results),
         expectation_results: parsed_expectation_results,
         feedback: parsed_feedback}
      else
        {test_results: response['out'],
         test_results_type: :unstructured,
         status: global_status(response['exit'], parsed_expectation_results),
         expectation_results: parsed_expectation_results,
         feedback: parsed_feedback}
      end
    end

    def self.structured_test_results?(response)
      response['testResults'].present?
    end

    def self.global_status(test_status, expectations_results)
      if test_status.to_sym == :passed && expectations_results.any? { |it| it[:result] == :failed }
        :passed_with_warnings
      else
        test_status.to_sym
      end
    end

    def self.parse_expectation_results(results)
      results.map do |it|
        {binding: it['expectation']['binding'],
         inspection: it['expectation']['inspection'],
         result: it['result'] ? :passed : :failed}
      end
    end

  end


end
