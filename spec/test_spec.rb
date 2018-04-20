require 'spec_helper'

describe Mumukit::Bridge::Runner do

  describe '#run_tests!' do
    let(:bridge) { Mumukit::Bridge::Runner.new('http://foo') }
    let(:request) { {} }
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
  end
end
