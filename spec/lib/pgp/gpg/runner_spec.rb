require 'spec_helper'

describe GPG::Runner do
  let(:runner) { GPG::Runner.new }

  let(:output_stub) { double }
  let(:exit_code_stub) { double }
  let(:handle_stub) { double }

  before {
    allow(handle_stub).to receive(:value).and_return(exit_code_stub)
  }

  describe 'version' do
    it 'reads gpg version' do
      allow(output_stub).to receive(:gets).and_return("gpg (GnuPG) 2.0.22\nlibgcrypt 1.5.3\nblah\nblah")
      allow(exit_code_stub).to receive(:success?).and_return(true)
      allow(Open3).to receive(:popen2e).with('gpg --version').and_yield(nil, output_stub, handle_stub)

      expect(runner.version).to eq('2.0.22')
    end
  end
end