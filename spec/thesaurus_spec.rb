require 'spec_helper'

describe Mumukit::Bridge::Thesaurus do
  let(:bridge) { Mumukit::Bridge::Thesaurus.new('http://foo') }
  before { expect_any_instance_of(Mumukit::Bridge::Thesaurus).to receive(:get).and_return(server_response) }

  describe '#runners' do
    let(:server_response) { {runners: ['http://bar.runners.mumuki.io']}.to_json }

    it { expect(bridge.runners.size).to eq 1 }
  end
end
