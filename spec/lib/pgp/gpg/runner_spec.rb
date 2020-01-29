require 'spec_helper'

describe GPG::Runner do
  let(:runner) { GPG::Runner.new }

  describe 'increment' do
    it 'adds 1' do
      expect(runner.increment(10)).to eq(11)
    end
  end
end