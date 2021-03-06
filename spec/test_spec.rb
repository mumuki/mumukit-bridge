require 'spec_helper'

describe Mumukit::Bridge::Runner do

  describe '#run_tests!' do
    let(:bridge) { Mumukit::Bridge::Runner.new('http://foo') }
    let(:request) { { test: '...' } }
    let(:response) { bridge.run_tests!(request) }

    before { expect_any_instance_of(Mumukit::Bridge::Runner).to receive(:do_json_post).and_return(server_response) }

    context 'structured data' do
      context 'when submission passed' do
        let(:server_response) { {
            'testResults' => [
                {'title' => 'true is true', 'status' => 'passed', 'result' => ''},
                {'title' => 'false is false', 'status' => 'passed', 'result' => ''},
            ]
        } }

        it { expect(response[:status]).to eq(:passed) }
        it { expect(response[:test_results]).to eq([{title: 'true is true', status: :passed, result: ''},
                                                    {title: 'false is false', status: :passed, result: ''}]) }
        it { expect(response[:response_type]).to eq(:structured) }
        it { expect(response[:expectation_results]).to be_empty }
        it { expect(response[:feedback]).to eq('') }
      end


      context 'when submission passed with expectation results' do
        let(:server_response) { {
            'testResults' => [
                {'title' => 'true is true', 'status' => 'passed', 'result' => ''},
                {'title' => 'false is false', 'status' => 'passed', 'result' => ''},
            ],
            'expectationResults' => [
                {'expectation' => {'binding' => 'bar', 'inspection' => 'HasBinding'}, 'result' => true}
            ]
        } }

        it { expect(response[:status]).to eq(:passed) }
        it { expect(response[:test_results]).to eq([{title: 'true is true', status: :passed, result: ''},
                                                    {title: 'false is false', status: :passed, result: ''}]) }
        it { expect(response[:response_type]).to eq(:structured) }
        it { expect(response[:expectation_results]).to eq [{binding: 'bar', inspection: 'HasBinding', result: :passed}] }
        it { expect(response[:feedback]).to eq('') }

      end

      context 'when submission failed' do
        let(:server_response) { {
            'testResults' => [
                {'title' => 'false is true', 'status' => 'failed', 'result' => 'true != false'},
                {'title' => 'false is false', 'status' => 'passed', 'result' => ''},
            ]
        } }

        it { expect(response[:status]).to eq(:failed) }
        it { expect(response[:test_results]).to eq([{title: 'false is true', status: :failed, result: 'true != false'},
                                                    {title: 'false is false', status: :passed, result: ''}]) }
        it { expect(response[:response_type]).to eq(:structured) }
        it { expect(response[:expectation_results]).to be_empty }
        it { expect(response[:feedback]).to eq('') }
      end

      context 'when submission failed with summary' do
        let(:server_response) { {
            'testResults' => [
                {'title' => 'f(1)', 'status' => 'failed', 'result' => '<error>', 'summary' => {'type' => 'unexpected_result'}},
                {'title' => 'f(2)', 'status' => 'failed', 'result' => '<error>', 'summary' => {'message' => 'check your tests'}},
                {'title' => 'f(3)', 'status' => 'failed', 'result' => '<error>', 'summary' => {'type' => 'undefined_reference', 'message' => 'There are undefined references'}},
                {'title' => 'f(4)', 'status' => 'passed', 'result' => ''},
            ]
        } }

        it { expect(response[:status]).to eq(:failed) }
        it { expect(response[:test_results]).to eq([{title: 'f(1)', status: :failed, result: '<error>', summary: {type: 'unexpected_result'}},
                                                    {title: 'f(2)', status: :failed, result: '<error>', summary: {message: 'check your tests'}},
                                                    {title: 'f(3)', status: :failed, result: '<error>', summary: {type: 'undefined_reference', message: 'There are undefined references'}},
                                                    {title: 'f(4)', status: :passed, result: ''}]) }
        it { expect(response[:response_type]).to eq(:structured) }
        it { expect(response[:expectation_results]).to be_empty }
        it { expect(response[:feedback]).to eq('') }
      end

      # this should not happen when runner is implemented using mumukit, since mumukit already removes empty summaries
      # and does not produce illegal summaries
      context 'when submission failed with empty or illegal summary' do
        let(:server_response) { {
            'testResults' => [
                {'title' => 'false is true', 'status' => 'failed', 'result' => 'true != false', 'summary' => {'type' => nil}},
                {'title' => 'nil is true', 'status' => 'failed', 'result' => 'nil != true', 'summary' => {'type' => ''}},
                {'title' => '1 is 1', 'status' => 'passed', 'result' => '', 'summary' => 'dfsdfsdf' },
                {'title' => 'false is false', 'status' => 'passed', 'result' => '', 'summary' => {} }
            ]
        } }

        it { expect(response[:status]).to eq(:failed) }
        it { expect(response[:test_results]).to eq([{title: 'false is true', status: :failed, result: 'true != false'},
                                                    {title: 'nil is true', status: :failed, result: 'nil != true'},
                                                    {title: '1 is 1', status: :passed, result: ''},
                                                    {title: 'false is false', status: :passed, result: ''}]) }
        it { expect(response[:response_type]).to eq(:structured) }
        it { expect(response[:expectation_results]).to be_empty }
        it { expect(response[:feedback]).to eq('') }
      end


      context 'when submission passed with warnings' do
        let(:server_response) { {
            'testResults' => [
                {'title' => 'true is true', 'status' => 'passed', 'result' => ''},
                {'title' => 'false is false', 'status' => 'passed', 'result' => ''},
            ],
            'expectationResults' => [
                {'expectation' => {'binding' => 'bar', 'inspection' => 'HasBinding'}, 'result' => true},
                {'expectation' => {'binding' => 'foo', 'inspection' => 'HasBinding'}, 'result' => false}
            ]
        } }

        it { expect(response[:status]).to eq(:passed_with_warnings) }
        it { expect(response[:test_results]).to eq([{title: 'true is true', status: :passed, result: ''},
                                                    {title: 'false is false', status: :passed, result: ''}]) }
        it { expect(response[:response_type]).to eq(:structured) }
        it { expect(response[:expectation_results]).to eq [{binding: 'bar', inspection: 'HasBinding', result: :passed},
                                                           {binding: 'foo', inspection: 'HasBinding', result: :failed}] }
        it { expect(response[:feedback]).to eq('') }

        context 'when the exercise has no tests' do
          let (:request) {{ test: '' }}

          it { expect(response[:status]).to eq(:failed) }
        end
      end
    end

    context 'unstructured data' do
      context 'when submission is ok' do
        let(:server_response) { {'out' => '0 failures', 'exit' => 'passed'} }

        it { expect(response[:status]).to eq(:passed) }
        it { expect(response[:result]).to include('0 failures') }
        it { expect(response[:test_results]).to be_empty }
        it { expect(response[:response_type]).to eq(:unstructured) }
        it { expect(response[:expectation_results]).to be_empty }
        it { expect(response[:feedback]).to eq('') }
      end

      context 'when submission is ok and has feedback' do
        let(:server_response) { {
            'out' => '0 failures',
            'exit' => 'passed',
            'feedback' => 'Keep up the good work!'
        } }

        it { expect(response[:status]).to eq(:passed) }
        it { expect(response[:result]).to include('0 failures') }
        it { expect(response[:test_results]).to be_empty }
        it { expect(response[:response_type]).to eq(:unstructured) }
        it { expect(response[:expectation_results]).to be_empty }
        it { expect(response[:feedback]).to eq('Keep up the good work!') }
      end

      context 'when submission is ok and has expectations' do
        let(:server_response) { {
            'out' => '0 failures',
            'exit' => 'passed',
            'expectationResults' => [
                {
                    'expectation' => {
                        'binding' => 'foo',
                        'inspection' => 'HasBinding'},
                    'result' => true
                }]}
        }

        it { expect(response[:status]).to eq(:passed) }
        it { expect(response[:result]).to include('0 failures') }
        it { expect(response[:test_results]).to be_empty }
        it { expect(response[:response_type]).to eq(:unstructured) }
        it { expect(response[:expectation_results]).to eq([{binding: 'foo', inspection: 'HasBinding', result: :passed}]) }
        it { expect(response[:feedback]).to eq('') }
      end


      context 'when submission is ok and has failed expectations' do
        let(:server_response) { {
            'out' => '0 failures',
            'exit' => 'passed',
            'expectationResults' => [
                {
                    'expectation' => {
                        'binding' => 'foo',
                        'inspection' => 'HasBinding'},
                    'result' => false
                }]}
        }

        it { expect(response[:status]).to eq(:passed_with_warnings) }
        it { expect(response[:result]).to include('0 failures') }
        it { expect(response[:test_results]).to be_empty }
        it { expect(response[:response_type]).to eq(:unstructured) }
        it { expect(response[:expectation_results]).to eq([{binding: 'foo', inspection: 'HasBinding', result: :failed}]) }
        it { expect(response[:feedback]).to eq('') }

        context 'when the exercise has no tests' do
          let (:request) {{ test: '' }}

          it { expect(response[:status]).to eq(:failed) }
        end
      end


      context 'when submission is not ok' do
        let(:server_response) { {'out' => 'should be equal 5 FAILED', 'exit' => 'failed'} }

        it { expect(response[:status]).to eq(:failed) }
        it { expect(response[:result]).to include('should be equal 5 FAILED') }
        it { expect(response[:test_results]).to be_empty }
        it { expect(response[:response_type]).to eq(:unstructured) }
        it { expect(response[:expectation_results]).to be_empty }
        it { expect(response[:feedback]).to eq('') }
      end


      context 'when submission errored' do
        let(:server_response) { {'out' => 'compilation error', 'exit' => 'errored'} }

        it { expect(response[:status]).to eq(:errored) }
        it { expect(response[:result]).to include('compilation error') }
        it { expect(response[:test_results]).to be_empty }
        it { expect(response[:response_type]).to eq(:unstructured) }
        it { expect(response[:expectation_results]).to be_empty }
        it { expect(response[:feedback]).to eq('') }
      end


      context 'when submission aborted' do
        let(:server_response) { {'out' => 'aborted. memory exceeded', 'exit' => 'aborted'} }

        it { expect(response[:status]).to eq(:aborted) }
        it { expect(response[:result]).to include('aborted. memory exceeded') }
        it { expect(response[:test_results]).to be_empty }
        it { expect(response[:response_type]).to eq(:unstructured) }
        it { expect(response[:expectation_results]).to be_empty }
        it { expect(response[:feedback]).to eq('') }
      end
    end

    context 'mixed data' do
      context 'when the exit code is ok and tests are ok' do
        let(:server_response) { {
            'testResults' => [
                {'title' => 'true is true', 'status' => 'passed', 'result' => ''}
            ],
            'out' => 'extra html',
            'exit' => 'passed'
        } }

        it { expect(response[:status]).to eq(:passed) }
        it { expect(response[:result]).to include('extra html') }
        it { expect(response[:test_results]).to eq([{title: 'true is true', status: :passed, result: ''}]) }
        it { expect(response[:response_type]).to eq(:mixed) }
        it { expect(response[:expectation_results]).to be_empty }
        it { expect(response[:feedback]).to eq('') }
      end

      context 'when tests are ok but the exit code is failed' do
        let(:server_response) { {
            'testResults' => [
                {'title' => 'true is true', 'status' => 'passed', 'result' => ''}
            ],
            'out' => 'extra html',
            'exit' => 'failed'
        } }

        it { expect(response[:status]).to eq(:failed) }
        it { expect(response[:result]).to include('extra html') }
        it { expect(response[:test_results]).to eq([{title: 'true is true', status: :passed, result: ''}]) }
        it { expect(response[:response_type]).to eq(:mixed) }
        it { expect(response[:expectation_results]).to be_empty }
        it { expect(response[:feedback]).to eq('') }
      end

      context 'when the exit code is ok but tests are failing' do
        let(:server_response) { {
            'testResults' => [
                {'title' => 'true is false', 'status' => 'failed', 'result' => 'true is not false'}
            ],
            'out' => 'extra html',
            'exit' => 'passed'
        } }

        it { expect(response[:status]).to eq(:failed) }
        it { expect(response[:result]).to include('extra html') }
        it { expect(response[:test_results]).to eq([{title: 'true is false', status: :failed, result: 'true is not false'}]) }
        it { expect(response[:response_type]).to eq(:mixed) }
        it { expect(response[:expectation_results]).to be_empty }
        it { expect(response[:feedback]).to eq('') }
      end
    end
  end
end
