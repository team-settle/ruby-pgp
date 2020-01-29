require 'spec_helper'

describe GPG::Runner do
  let(:runner) { GPG::Runner.new }

  def setup_process(command, success, output)
    output_stub = double
    exit_code_stub = double
    handle_stub = double

    allow(handle_stub).to receive(:value).and_return(exit_code_stub)

    allow(output_stub).to receive(:gets).and_return(output)
    allow(exit_code_stub).to receive(:success?).and_return(success)
    allow(Open3).to receive(:popen2e).with(command).and_yield(nil, output_stub, handle_stub)
  end

  describe 'version' do
    it 'reads gpg version' do
      setup_process('gpg --version', true, "gpg (GnuPG) 2.0.22\nlibgcrypt 1.5.3\nblah\nblah")
      expect(runner.version).to eq('2.0.22')
    end

    it 'returns empty when gpg fails' do
      setup_process('gpg --version', false, nil)
      expect(runner.version).to eq('')
    end
  end
end