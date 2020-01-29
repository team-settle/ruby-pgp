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

  describe 'is_gpg2?' do
    it 'returns true when version 2 is default' do
      allow(runner).to receive(:version).and_return('2.0.22')
      expect(runner.is_gpg2?).to be_truthy
    end

    it 'returns false when version 1 is default' do
      allow(runner).to receive(:version).and_return('1.12.22')
      expect(runner.is_gpg2?).to be_falsey
    end

    it 'returns false when there is no gpg' do
      allow(runner).to receive(:version).and_return('')
      expect(runner.is_gpg2?).to be_falsey
    end
  end
end