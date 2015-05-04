require 'rspec/mocks'
require_relative '../lib/mumukit/bridge'

include Mumukit::Bridge

describe Bridge do

  describe '#run_tests!' do
    let(:bridge) { Bridge.new('http://foo') }
    let(:request) { {} }
    let(:response) { bridge.run_tests!(request) }

    before { expect_any_instance_of(Bridge).to receive(:post_to_server).and_return(server_response) }

    context 'when submission is ok' do
      let(:server_response) { {'out' => '0 failures', 'exit' => 'passed'} }

      it { expect(response[:status]).to eq('passed') }
      it { expect(response[:result]).to include('0 failures') }
      it { expect(response[:expectation_results]).to eq([]) }
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

      it { expect(response[:status]).to eq('passed') }
      it { expect(response[:result]).to include('0 failures') }
      it { expect(response[:expectation_results]).to eq([{binding: 'foo', inspection: 'HasBinding', result: :passed}]) }
    end

    context 'when submission is not ok' do
      let(:server_response) { {'out' => 'should be equal 5 FAILED', 'exit' => 'failed'} }

      it { expect(response[:status]).to eq('failed') }
      it { expect(response[:result]).to include('should be equal 5 FAILED') }
      it { expect(response[:expectation_results]).to eq([]) }
    end

  end
end
