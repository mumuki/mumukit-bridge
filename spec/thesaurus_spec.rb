require 'spec_helper'

describe Mumukit::Bridge::Bibliotheca do
  let(:bridge) { Mumukit::Bridge::Thesaurus.new('http://foo') }
  before { expect_any_instance_of(Mumukit::Bridge::Thesaurus).to receive(:get).and_return(server_response) }

  describe '#langauges' do
    let(:server_response) { {'languages' => [{'name' => 'ruby', 'url' => 'http://bar'}]} }

    it { expect(bridge.languages.size).to eq 1 }
  end

  describe '#language' do
    let(:server_response) { {'name' => 'ruby', 'version' => '1'} }

    it { expect(bridge.language('ruby')['version']).to eq '1' }
  end
end
