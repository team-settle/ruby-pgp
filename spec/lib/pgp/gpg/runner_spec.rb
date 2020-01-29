require 'spec_helper'

describe GPG::Runner do
  include ProcessHelper

  let(:runner) { GPG::Runner.new }

  describe :version_default do
    it 'reads gpg version' do
      setup_process('gpg --version', true, "gpg (GnuPG) 2.0.22\nlibgcrypt 1.5.3\nblah\nblah")
      expect(runner.version_default).to eq('2.0.22')
    end

    it 'returns empty when gpg fails' do
      setup_process('gpg --version', false, nil)
      expect(runner.version_default).to eq('')
    end
  end

  describe :version_gpg1 do
    it 'reads gpg1 version' do
      setup_process('gpg1 --version', true, "gpg (GnuPG) 1.4.20\nlibgcrypt 1.5.3\nblah\nblah")
      expect(runner.version_gpg1).to eq('1.4.20')
    end

    it 'returns empty when gpg1 fails' do
      setup_process('gpg1 --version', false, nil)
      expect(runner.version_gpg1).to eq('')
    end
  end

  describe :default_gpg_is_v2? do
    it 'returns true when version 2 is default' do
      allow(runner).to receive(:version_default).and_return('2.0.22')
      expect(runner.default_gpg_is_v2?).to be_truthy
    end

    it 'returns false when version 1 is default' do
      allow(runner).to receive(:version_default).and_return('1.12.22')
      expect(runner.default_gpg_is_v2?).to be_falsey
    end

    it 'returns false when there is no gpg' do
      allow(runner).to receive(:version_default).and_return('')
      expect(runner.default_gpg_is_v2?).to be_falsey
    end
  end

  describe :default_gpg_is_v1? do
    it 'returns false when version 2 is default' do
      allow(runner).to receive(:version_default).and_return('2.0.22')
      expect(runner.default_gpg_is_v1?).to be_falsey
    end

    it 'returns true when version 1 is default' do
      allow(runner).to receive(:version_default).and_return('1.12.22')
      expect(runner.default_gpg_is_v1?).to be_truthy
    end

    it 'returns false when there is no gpg' do
      allow(runner).to receive(:version_default).and_return('')
      expect(runner.default_gpg_is_v1?).to be_falsey
    end
  end

  describe :should_switch_to_gpg1? do
    it 'returns false when the default gpg version is 1' do
      allow(runner).to receive(:version_default).and_return('1.1.0')

      expect(runner.should_switch_to_gpg1?).to be_falsey
    end

    it 'returns true when the default gpg version is 2' do
      allow(runner).to receive(:version_default).and_return('2.0.0')
      allow(runner).to receive(:version_gpg1).and_return('1.2.0')

      expect(runner.should_switch_to_gpg1?).to be_truthy
    end

    it 'returns false when the default gpg version is 2 but there is no gpg1 installed' do
      allow(runner).to receive(:version_default).and_return('2.0.0')
      allow(runner).to receive(:version_gpg1).and_return('')

      expect(runner.should_switch_to_gpg1?).to be_falsey
    end

    it 'returns true when only gpg1 installed' do
      allow(runner).to receive(:version_default).and_return('')
      allow(runner).to receive(:version_gpg1).and_return('1.2.2')

      expect(runner.should_switch_to_gpg1?).to be_truthy
    end

    it 'returns false when no gpg installed' do
      allow(runner).to receive(:version_default).and_return('')
      allow(runner).to receive(:version_gpg1).and_return('')

      expect(runner.should_switch_to_gpg1?).to be_falsey
    end
  end
end