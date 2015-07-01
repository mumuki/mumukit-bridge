require 'rspec/mocks'
require_relative '../lib/mumukit/bridge'

include Mumukit::Bridge

describe Bridge do

  describe '#run_tests!' do
    let(:bridge) { Bridge.new('http://foo') }
    let(:request) { {} }
    let(:response) { bridge.run_tests!(request) }

    before { expect_any_instance_of(Bridge).to receive(:post_to_server).and_return(server_response) }

    context 'structured data' do
      context 'when submission passed' do
        let(:server_response) { {
            'testResults' => [
                {'title' => 'true is true', 'status' => 'passed', 'result' => ''},
                {'title' => 'false is false', 'status' => 'passed', 'result' => ''},
            ]
        } }

        it { expect(response[:status]).to eq(:passed) }
        it { expect(response[:test_results]).to eq(server_response.deep_symbolize_keys) }
        it { expect(response[:test_results_type]).to eq(:structured) }
        it { expect(response[:expectation_results]).to eq([]) }
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
        it { expect(response[:test_results]).to eq(server_response.deep_symbolize_keys) }
        it { expect(response[:test_results_type]).to eq(:structured) }
        it { expect(response[:expectation_results]).to eq [{binding: 'bar', inspection: 'HasBinding', result: true}] }
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
        it { expect(response[:test_results]).to eq(server_response.deep_symbolize_keys) }
        it { expect(response[:test_results_type]).to eq(:structured) }
        it { expect(response[:expectation_results]).to eq([]) }
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
        it { expect(response[:test_results]).to eq(server_response.slice('testResults').deep_symbolize_keys) }
        it { expect(response[:test_results_type]).to eq(:structured) }
        it { expect(response[:expectation_results]).to eq [{binding: 'bar', inspection: 'HasBinding', result: true},
                                                           {binding: 'foo', inspection: 'HasBinding', result: false}] }
        it { expect(response[:feedback]).to eq('') }
      end
    end


    context 'unstructured data' do
      context 'when submission is ok' do
        let(:server_response) { {'out' => '0 failures', 'exit' => 'passed'} }

        it { expect(response[:status]).to eq('passed') }
        it { expect(response[:test_results]).to include('0 failures') }
        it { expect(response[:test_results_type]).to eq(:unstructured) }
        it { expect(response[:expectation_results]).to eq([]) }
        it { expect(response[:feedback]).to eq('') }
      end

      context 'when submission is ok and has feedback' do
        let(:server_response) { {
            'out' => '0 failures',
            'exit' => 'passed',
            'feedback' => 'Keep up the good work!'
        } }

        it { expect(response[:status]).to eq('passed') }
        it { expect(response[:test_results]).to include('0 failures') }
        it { expect(response[:test_results_type]).to eq(:unstructured) }
        it { expect(response[:expectation_results]).to eq([]) }
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
        it { expect(response[:test_results]).to include('0 failures') }
        it { expect(response[:test_results_type]).to eq(:unstructured) }
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
        it { expect(response[:test_results]).to include('0 failures') }
        it { expect(response[:test_results_type]).to eq(:unstructured) }
        it { expect(response[:expectation_results]).to eq([{binding: 'foo', inspection: 'HasBinding', result: :passed}]) }
        it { expect(response[:feedback]).to eq('') }
      end


      context 'when submission is not ok' do
        let(:server_response) { {'out' => 'should be equal 5 FAILED', 'exit' => 'failed'} }

        it { expect(response[:status]).to eq(:failed) }
        it { expect(response[:test_results]).to include('should be equal 5 FAILED') }
        it { expect(response[:test_results_type]).to eq(:unstructured) }
        it { expect(response[:expectation_results]).to eq([]) }
        it { expect(response[:feedback]).to eq('') }
      end


      context 'when submission errored' do
        let(:server_response) { {'out' => 'compilation error', 'exit' => 'errored'} }

        it { expect(response[:status]).to eq(:errored) }
        it { expect(response[:test_results]).to include('compilation error') }
        it { expect(response[:test_results_type]).to eq(:unstructured) }
        it { expect(response[:expectation_results]).to eq([]) }
        it { expect(response[:feedback]).to eq('') }
      end


      context 'when submission aborted' do
        let(:server_response) { {'out' => 'aborted. memory exceeded', 'exit' => 'aborted'} }

        it { expect(response[:status]).to eq(:aborted) }
        it { expect(response[:test_results]).to include('aborted. memory exceeded') }
        it { expect(response[:test_results_type]).to eq(:unstructured) }
        it { expect(response[:expectation_results]).to eq([]) }
        it { expect(response[:feedback]).to eq('') }
      end
    end
  end
end
