require 'spec_helper'

describe GPG::Runner do
  include ProcessHelper

  let(:runner) { GPG::Runner.new(verbose: true) }

  describe :version_default do
    it 'reads gpg version' do
      setup_process('gpg2 --version', true, "gpg (GnuPG) 2.0.22\nlibgcrypt 1.5.3\nblah\nblah")
      expect(runner.version_default).to eq('2.0.22')
    end

    it 'returns empty when gpg fails' do
      setup_process('gpg2 --version', false, nil)
      expect(runner.version_default).to eq('')
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
      setup_process('gpg2 --quiet --list-secret-keys --fingerprint', true, seeded_output)

      expect(runner.read_private_key_fingerprints).to eq(fingerprints)
    end

    it 'returns empty when there are no secret keys' do
      setup_process('gpg2 --quiet --list-secret-keys --fingerprint', true, nil)

      expect(runner.read_private_key_fingerprints).to eq([])
    end

    it 'returns empty when gpg fails' do
      setup_process('gpg2 --quiet --list-secret-keys --fingerprint', false, nil)

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

      setup_process('gpg2 --quiet --list-keys --fingerprint', true, seeded_output)

      expect(runner.read_public_key_fingerprints).to eq(fingerprints)
    end

    it 'returns empty when there are no public keys' do
      setup_process('gpg2 --quiet --list-keys --fingerprint', false, '')

      expect(runner.read_public_key_fingerprints).to eq([])
    end

    it 'returns empty when gpg fails' do
      setup_process('gpg2 --quiet --list-keys --fingerprint', false, nil)

      expect(runner.read_public_key_fingerprints).to eq([])
    end
  end

  describe :delete_private_key do
    it 'deletes they key with the specified fingerprint' do
      setup_process('gpg2 --quiet --batch --delete-secret-key AAAAAAA', true, '')

      expect(runner.delete_private_key('AAAAAAA')).to eq(true)

      expect(Open3).to have_received(:popen2e)
    end

    it 'returns false when the deletion fails' do
      setup_process('gpg2 --quiet --batch --delete-secret-key AAAAAAA', false, '')

      expect(runner.delete_private_key('AAAAAAA')).to eq(false)
    end
  end

  describe :delete_public_key do
    it 'deletes the public key with the specified fingerprint' do
      setup_process('gpg2 --quiet --batch --delete-key AAAAAAA', true, '')

      expect(runner.delete_public_key('AAAAAAA')).to eq(true)

      expect(Open3).to have_received(:popen2e)
    end

    it 'returns false when the deletion fails' do
      setup_process('gpg2 --quiet --batch --delete-key AAAAAAA', false, '')

      expect(runner.delete_public_key('AAAAAAA')).to eq(false)
    end
  end

  describe :import_key_from_file do
    before { allow(File).to receive(:read) }

    it 'imports the key contents from a file' do
      setup_process('gpg2 --quiet --batch --import "~/secret.pgp"', true, '')

      expect(runner.import_key_from_file('~/secret.pgp')).to eq(true)

      expect(Open3).to have_received(:popen2e)
    end

    it 'returns false when the import fails' do
      setup_process('gpg2 --quiet --batch --import "~/secret.pgp"', false, '')

      expect(runner.import_key_from_file('~/secret.pgp')).to eq(false)
    end
  end

  describe :verify_signature_file do
    before { allow(File).to receive(:read) }

    it 'verifies the signature contents from a file' do
      setup_process('gpg2 --quiet --batch --verify "~/signature.asc"', true, '')

      expect(runner.verify_signature_file('~/signature.asc')).to eq(true)

      expect(Open3).to have_received(:popen2e)
    end

    it 'returns false when verification fails' do
      setup_process('gpg2 --quiet --batch --verify "~/signature.asc"', false, '')

      expect(runner.verify_signature_file('~/signature.asc')).to eq(false)
    end

    it 'verifies and reads the signature contents from a file' do
      setup_process('gpg2 --quiet --batch --output "~/output.txt" "~/signature.asc"', true, '')

      expect(runner.verify_signature_file('~/signature.asc', '~/output.txt')).to eq(true)

      expect(Open3).to have_received(:popen2e)
    end

    it 'returns false when signature data read fails' do
      setup_process('gpg2 --quiet --batch --output "~/output.txt" "~/signature.asc"', false, '')

      expect(runner.verify_signature_file('~/signature.asc', '~/output.txt')).to eq(false)

      expect(Open3).to have_received(:popen2e)
    end
  end

  describe :decrypt_file do
    context 'without passphrase ' do
      it 'decrypts a file' do
        setup_process('gpg2 --quiet --batch --yes --ignore-mdc-error --output "/tmp/plaintext.txt" --decrypt "~/encrypted_text.txt"', true, '')

        expect(runner.decrypt_file('~/encrypted_text.txt', '/tmp/plaintext.txt')).to eq(true)

        expect(Open3).to have_received(:popen2e)
      end

      it 'returns false when decryption failed' do
        setup_process('gpg2 --quiet --batch --yes --ignore-mdc-error --output "/tmp/plaintext.txt" --decrypt "~/encrypted_text.txt"', false, '')

        expect(runner.decrypt_file('~/encrypted_text.txt', '/tmp/plaintext.txt')).to eq(false)
      end
    end

    context 'with passphrase' do
      context 'gpg 2.0' do
        before {
          allow(runner).to receive(:version_default).and_return('2.0.4')
        }

        it 'decrypts a file' do
          setup_process('gpg2 --quiet --batch --passphrase "supersecret111" --yes --ignore-mdc-error --output "/tmp/plaintext.txt" --decrypt "~/encrypted_text.txt"', true, '')

          expect(runner.decrypt_file('~/encrypted_text.txt', '/tmp/plaintext.txt', 'supersecret111')).to eq(true)

          expect(Open3).to have_received(:popen2e)
        end

        it 'returns false when decryption failed' do
          setup_process('gpg2 --quiet --batch --passphrase "supersecret111" --yes --ignore-mdc-error --output "/tmp/plaintext.txt" --decrypt "~/encrypted_text.txt"', false, '')

          expect(runner.decrypt_file('~/encrypted_text.txt', '/tmp/plaintext.txt', 'supersecret111')).to eq(false)
        end
      end
    end
  end
end