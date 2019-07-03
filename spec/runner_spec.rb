require 'spec_helper'

describe Mumukit::Bridge::Runner do
  let(:bridge) { Mumukit::Bridge::Runner.new('http://foo', 10, foo: 'bar') }

  describe 'headers' do
    it { expect(bridge.headers).to eq foo: 'bar' }
  end
end
