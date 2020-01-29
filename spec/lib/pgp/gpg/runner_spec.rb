require 'spec_helper'

describe GPG::Runner do
  include ProcessHelper
  
  let(:runner) { GPG::Runner.new }

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