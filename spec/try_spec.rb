require 'spec_helper'


describe Mumukit::Bridge::Runner do

  describe '#run_try!' do
    let(:bridge) { Mumukit::Bridge::Runner.new('http://foo') }
    let(:request) { {} }
    let(:response) { bridge.run_try!(request) }

    before { expect_any_instance_of(Mumukit::Bridge::Runner).to receive(:do_post).and_return(server_response) }

    context 'when goal achived' do
      let(:server_response) { {
          'exit' => 'passed',
          'out' => 'baz',
          'queryResult' => { 'status' => 'passed', 'result' => 'foo bar' }
      } }
      it { expect(response[:status]).to eq(:passed) }
      it { expect(response[:result]).to eq('baz') }
      it { expect(response[:query_result]).to eq status: :passed, result: 'foo bar' }
    end

    context 'when quey passes, but goal was not achived' do
      let(:server_response) { {
          'exit' => 'failed',
          'out' => '',
          'queryResult' => { 'status' => 'passed', 'result' => 'foo bar' }
      } }
      it { expect(response[:status]).to eq(:failed) }
      it { expect(response[:result]).to eq('') }
      it { expect(response[:query_result]).to eq status:  :passed, result: 'foo bar' }
    end

    context 'when quey fails and goal was not achived' do
      let(:server_response) { {
          'exit' => 'failed',
          'out' => '',
          'queryResult' => { 'status' => 'failed', 'result' => 'bar' }
      } }
      it { expect(response[:status]).to eq(:failed) }
      it { expect(response[:result]).to eq('') }
      it { expect(response[:query_result]).to eq status:  :failed, result: 'bar' }
    end
  end
end
