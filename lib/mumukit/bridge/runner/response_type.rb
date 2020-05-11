module Mumukit::Bridge
  module ResponseType
    class Base
      def parse(response, request)
        expectation_results = parse_expectation_results(response['expectationResults'] || [])
        feedback = response['feedback'] || ''
        result = response['out'] || ''

        build_hash(response).
            merge(feedback: feedback, expectation_results: expectation_results, result: result).
            update(status: expectation_results.fetch_mumuki_status(:result)) { |_, t, e| global_status(t, e, request) }
      end

      def global_status(test_status, expectation_status, request)
        if test_status.passed? && expectation_status.failed?
          request[:test].blank? ? :failed : :passed_with_warnings
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
        results.map do |it|
          { summary: safe_compact(it['summary'])&.symbolize_keys.presence }
            .compact
            .merge(
              title: it['title'],
              status: it['status'].to_sym,
              result: it['result'])
        end
      end

      def safe_compact(hash)
        hash.try { |it| it.transform_values(&:presence).compact rescue nil }
      end
    end

    class Unstructured < Base
      def build_hash(response)
        {response_type: :unstructured,
         test_results: [],
         status: response['exit'].to_sym}
      end
    end

    class Mixed < Structured
      def build_hash(response)
        structured_results = super(response)
        structured_results.merge response_type: :mixed,
                                 status: status(structured_results[:status], response['exit'].to_sym)
      end

      private

      def status(tests_status, output_status)
        tests_status.passed? && output_status.passed? ? :passed : :failed
      end
    end

    def self.structured_test_results?(response)
      response['testResults'].present?
    end

    def self.mixed_test_results?(response)
      structured_test_results?(response) && response['out'].present?
    end

    def self.for_response(response)
      if mixed_test_results?(response)
        Mixed.new
      elsif structured_test_results?(response)
        Structured.new
      else
        Unstructured.new
      end
    end
  end
end
