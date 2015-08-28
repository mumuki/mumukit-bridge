require 'rspec/mocks'
require_relative '../lib/mumukit/bridge'

include Mumukit::Bridge

describe Bridge do

  describe '#run_query!' do
    let(:bridge) { Bridge.new('http://foo') }
    let(:request) { {} }
    let(:response) { bridge.run_query!(request) }

    before { expect_any_instance_of(Bridge).to receive(:post_to_server).and_return(server_response) }

    context 'when submission passed' do
      let(:server_response) { {
          'exit' => 'passed',
          'out' => '6'
      } }
      it { expect(response[:status]).to eq(:passed) }
      it { expect(response[:result]).to eq('6') }
    end
  end
end
