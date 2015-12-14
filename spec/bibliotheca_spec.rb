require 'spec_helper'

describe Mumukit::Bridge::Bibliotheca do

  describe '#guides' do
    let(:bridge) { Mumukit::Bridge::Bibliotheca.new('http://foo') }
    let(:response) { bridge.guides }

    before { expect_any_instance_of(Mumukit::Bridge::Bibliotheca).to receive(:get).and_return(server_response) }

    let(:server_response) {
      {'guides' => [
          {'id' => 'ab0296d7984d80cb', 'slug' => 'pdep-utn/mumuki-logico-tp-sturbacks', 'language' => 'prolog'},
          {'id' => '80d1a82f261ada8c', 'slug' => 'mumuki/guia-funcional-javascript-1', 'language' => 'javascript'}]}
    }
    
    it { expect(response.size).to eq 2 }
  end
end
