require 'spec_helper'

describe Mumukit::Bridge::Runner do
  describe 'headers' do
    let(:bridge) { Mumukit::Bridge::Runner.new('http://foo', 10, foo: 'bar') }

    it { expect(bridge.headers).to eq foo: 'bar' }
  end
end
