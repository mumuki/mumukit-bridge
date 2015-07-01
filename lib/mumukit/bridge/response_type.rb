module Mumukit::Bridge
  module ResponseType
    class Base
      def parse(response)
        expectation_results = parse_expectation_results(response['expectationResults'] || [])
        feedback = response['feedback'] || ''

        build_hash(expectation_results, response).merge(
            feedback: feedback,
            expectation_results: expectation_results)
      end

      def global_status(test_status, expectations_results)
        if test_status.to_sym == :passed && expectations_results.any? { |it| it[:result] == :failed }
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
    end

    class Structured < Base
      def build_hash(expectation_results, response)
        test_results = parse_test_results(response['testResults'])
        {test_results_type: :structured,
         test_results: test_results,
         status: global_status(
             test_results[:test_results].any? { |it| it[:status] == :failed } ? :failed : :passed, expectation_results)}
      end

      private

      def parse_test_results(results)
        {test_results:
             results.map { |it| {
                 title: it['title'],
                 status: it['status'].to_sym,
                 result: it['result']} }}
      end
    end

    class Unstructured < Base
      def build_hash(expectation_results, response)
        {test_results: response['out'],
         test_results_type: :unstructured,
         status: global_status(response['exit'], expectation_results)}
      end
    end

    def self.structured_test_results?(response)
      response['testResults'].present?
    end

    def self.for_response(response)
      structured_test_results?(response) ? Structured.new : Unstructured.new
    end
  end
end
