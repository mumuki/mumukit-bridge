require 'spec_helper'

describe Mumukit::Bridge::Runner do

  describe '#run_query!' do
    let(:bridge) { Mumukit::Bridge::Runner.new('http://foo') }
    let(:request) { {} }
    let(:response) { bridge.run_query!(request) }

    before { expect_any_instance_of(Mumukit::Bridge::Runner).to receive(:do_json_post).and_return(server_response) }

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
