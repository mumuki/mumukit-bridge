module Mumukit::Bridge
  module ResponseType
    class Base
      def parse(response)
        expectation_results = parse_expectation_results(response['expectationResults'] || [])
        feedback = response['feedback'] || ''
        result = response['out'] || ''

        build_hash(response).
            merge(feedback: feedback, expectation_results: expectation_results, result: result).
            update(status: expectation_results.fetch_mumuki_status(:result)) { |_, t, e| global_status(t, e) }
      end

      def global_status(test_status, expectation_status)
        if test_status == :passed && expectation_status == :failed
          :passed_with_warnings
        else
          test_status
        end
      end

      def parse_expectation_results(results)
        results.map do |it|
          {binding: it['expectation']['binding'],
           inspection: it['expectation']['inspection'],
           result: it['result'].to_mumuki_status}
        end
      end
    end

    class Structured < Base
      def build_hash(response)
        test_results = parse_test_results(response['testResults'])
        {response_type: :structured,
         test_results: test_results,
         status: test_results.fetch_mumuki_status(:status)}
      end

      private

      def parse_test_results(results)
         results.map { |it| {
             title: it['title'],
             status: it['status'].to_sym,
             result: it['result']} }
      end
    end

    class Unstructured < Base
      def build_hash(response)
        {response_type: :unstructured,
         test_results: [],
         status: response['exit'].to_sym}
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
