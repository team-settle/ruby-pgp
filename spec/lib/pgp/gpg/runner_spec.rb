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

  describe :binary_path_gpg1 do
    it 'returns gpg1 path' do
      setup_process('which gpg1', true, '/usr/bin/gpg1')
      expect(runner.binary_path_gpg1).to eq('/usr/bin/gpg1')
    end

    it 'returns empty when which command fails' do
      setup_process('which gpg1', false, nil)
      expect(runner.binary_path_gpg1).to eq('')
    end
  end

  describe :read_private_key_fingerprints do
    it 'reads all the private key fingerprints' do
      fingerprints = [
        '23AD063A33C2EBE09F9A71ED9539E22A3388EE24',
        'A99BFCC3B6B952D66AFC1F3C48508D311DD34131'
      ]
      seeded_output = '''
/root/.gnupg/secring.gpg
------------------------
sec   2048R/3388EE24 2013-03-04
      Key fingerprint = 23AD 063A 33C2 EBE0 9F9A  71ED 9539 E22A 3388 EE24
uid                  Chris Nelson <superchrisnelson@gmail.com>
ssb   2048R/349BAAD3 2013-03-04

sec   2048R/1DD34131 2012-06-14
      Key fingerprint = A99B FCC3 B6B9 52D6 6AFC  1F3C 4850 8D31 1DD3 4131
uid                  JRuby BG PGP Bug <foo@bar.com>
ssb   2048R/412E5D21 2012-06-14
'''
      setup_process('gpg --quiet --list-secret-keys --fingerprint', true, seeded_output)

      expect(runner.read_private_key_fingerprints).to eq(fingerprints)
    end

    it 'returns empty when there are no secret keys' do
      setup_process('gpg --quiet --list-secret-keys --fingerprint', false, '')

      expect(runner.read_private_key_fingerprints).to eq([])
    end

    it 'returns empty when gpg fails' do
      setup_process('gpg --quiet --list-secret-keys --fingerprint', false, nil)

      expect(runner.read_private_key_fingerprints).to eq([])
    end
  end

  describe :read_public_key_fingerprints do
    it 'reads all the public key fingerprints' do
      fingerprints = [
        '23AD063A33C2EBE09F9A71ED9539E22A3388EE24',
        'A99BFCC3B6B952D66AFC1F3C48508D311DD34131'
      ]
      seeded_output = '''
/root/.gnupg/pubring.gpg
------------------------
pub   2048R/3388EE24 2013-03-04
      Key fingerprint = 23AD 063A 33C2 EBE0 9F9A  71ED 9539 E22A 3388 EE24
uid                  Chris Nelson <superchrisnelson@gmail.com>
sub   2048R/349BAAD3 2013-03-04

pub   2048R/1DD34131 2012-06-14
      Key fingerprint = A99B FCC3 B6B9 52D6 6AFC  1F3C 4850 8D31 1DD3 4131
uid                  JRuby BG PGP Bug <foo@bar.com>
sub   2048R/412E5D21 2012-06-14
'''

      setup_process('gpg --quiet --list-keys --fingerprint', true, seeded_output)

      expect(runner.read_public_key_fingerprints).to eq(fingerprints)
    end

    it 'returns empty when there are no public keys' do
      setup_process('gpg --quiet --list-keys --fingerprint', false, '')

      expect(runner.read_public_key_fingerprints).to eq([])
    end

    it 'returns empty when gpg fails' do
      setup_process('gpg --quiet --list-keys --fingerprint', false, nil)

      expect(runner.read_public_key_fingerprints).to eq([])
    end
  end

  describe :delete_private_key do
    it 'deletes they key with the specified fingerprint' do
      setup_process('gpg --quiet --batch --delete-secret-key AAAAAAA', true, '')

      expect(runner.delete_private_key('AAAAAAA')).to eq(true)

      expect(Open3).to have_received(:popen2e)
    end

    it 'returns false when the deletion fails' do
      setup_process('gpg --quiet --batch --delete-secret-key AAAAAAA', false, '')

      expect(runner.delete_private_key('AAAAAAA')).to eq(false)
    end
  end

  describe :delete_public_key do
    it 'deletes the public key with the specified fingerprint' do
      setup_process('gpg --quiet --batch --delete-key AAAAAAA', true, '')

      expect(runner.delete_public_key('AAAAAAA')).to eq(true)

      expect(Open3).to have_received(:popen2e)
    end

    it 'returns false when the deletion fails' do
      setup_process('gpg --quiet --batch --delete-key AAAAAAA', false, '')

      expect(runner.delete_public_key('AAAAAAA')).to eq(false)
    end
  end

  describe :delete_all_private_keys do
    it 'deletes all the private keys' do
      allow(runner).to receive(:read_private_key_fingerprints).and_return(['fp1', 'fp2'])
      allow(runner).to receive(:delete_private_key)

      runner.delete_all_private_keys

      expect(runner).to have_received(:delete_private_key).with('fp1')
      expect(runner).to have_received(:delete_private_key).with('fp2')
    end
  end

  describe :delete_all_public_keys do
    it 'deletes all the public keys' do
      allow(runner).to receive(:read_public_key_fingerprints).and_return(['fp1', 'fp2'])
      allow(runner).to receive(:delete_public_key)

      runner.delete_all_public_keys

      expect(runner).to have_received(:delete_public_key).with('fp1')
      expect(runner).to have_received(:delete_public_key).with('fp2')
    end
  end

  describe :delete_all_keys do
    it 'deletes all private and public keys' do
      deleted_fingerprints = []

      allow(runner).to receive(:read_private_key_fingerprints).and_return(['privfp1', 'privfp2'])
      allow(runner).to receive(:delete_private_key) { |k| deleted_fingerprints << k }

      allow(runner).to receive(:read_public_key_fingerprints).and_return(['pubfp1', 'pubfp2'])
      allow(runner).to receive(:delete_public_key) { |k| deleted_fingerprints << k }

      runner.delete_all_keys

      expect(deleted_fingerprints).to eq(['privfp1', 'privfp2', 'pubfp1', 'pubfp2'])
    end
  end
end