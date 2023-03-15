require 'spec_helper'

describe Mumukit::Bridge::Bibliotheca do
  let(:bridge) { Mumukit::Bridge::Bibliotheca.new('http://foo') }


  describe '#guides' do
    let(:response) { bridge.guides }
    before { expect_any_instance_of(Mumukit::Bridge::Bibliotheca).to receive(:get).and_return(server_response) }

    let(:server_response) {
      {'guides' => [
          {'id' => 'ab0296d7984d80cb', 'slug' => 'pdep-utn/mumuki-logico-tp-sturbacks', 'language' => 'prolog'},
          {'id' => '80d1a82f261ada8c', 'slug' => 'mumuki/guia-funcional-javascript-1', 'language' => 'javascript'}]}
    }
    it { expect(response.size).to eq 2 }
  end

  describe '#topic' do
    let(:response) { bridge.topic('bar/baz') }
    before { expect_any_instance_of(Mumukit::Bridge::Bibliotheca).to receive(:get).and_return(server_response) }

    let(:server_response) {
      {'name' => 'foo', 'lessons' => ['bar/foobar']}
    }

    it { expect(response['name']).to eq 'foo' }
  end

  describe '#headers' do
    context 'has headers' do
      let(:bridge) { Mumukit::Bridge::Bibliotheca.new('http://foo', 10, foo: 'bar') }
      it { expect(bridge.headers).to eq foo: 'bar' }
    end
    context 'has no headers' do
      let(:bridge) { Mumukit::Bridge::Bibliotheca.new('http://foo') }
      it { expect(bridge.headers).to eq({}) }
    end
  end
end
