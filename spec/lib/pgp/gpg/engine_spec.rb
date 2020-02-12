require 'spec_helper'

describe GPG::Engine do
  include TempHelper

  let(:engine) { GPG::Engine.new }
  let(:runner) { engine.runner }

  def setup_valid_gpg_version
    allow(runner).to receive(:version_default).and_return('2.0.4')
  end

  def setup_invalid_gpg_version
    allow(runner).to receive(:version_default).and_return('1.9.14')
  end

  describe :delete_all_private_keys do
    it 'deletes all the private keys' do
      setup_valid_gpg_version
      allow(runner).to receive(:read_private_key_fingerprints).and_return(['fp1', 'fp2'])
      allow(runner).to receive(:delete_private_key)

      engine.delete_all_private_keys

      expect(runner).to have_received(:delete_private_key).with('fp1')
      expect(runner).to have_received(:delete_private_key).with('fp2')
    end

    it 'fails when gpg is not correctly installed' do
      setup_invalid_gpg_version

      expect{
        engine.delete_all_private_keys
      }.to raise_exception('GPG Version is incorrect')
    end
  end

  describe :delete_all_public_keys do
    it 'deletes all the public keys' do
      setup_valid_gpg_version
      allow(runner).to receive(:read_public_key_fingerprints).and_return(['fp1', 'fp2'])
      allow(runner).to receive(:delete_public_key)

      engine.delete_all_public_keys

      expect(runner).to have_received(:delete_public_key).with('fp1')
      expect(runner).to have_received(:delete_public_key).with('fp2')
    end

    it 'fails when gpg is not correctly installed' do
      setup_invalid_gpg_version

      expect{
        engine.delete_all_public_keys
      }.to raise_exception('GPG Version is incorrect')
    end
  end

  describe :delete_all_keys do
    it 'deletes all private and public keys' do
      deleted_fingerprints = []

      allow(runner).to receive(:read_private_key_fingerprints).and_return(['privfp1', 'privfp2'])
      allow(runner).to receive(:delete_private_key) { |k| deleted_fingerprints << k }

      allow(runner).to receive(:read_public_key_fingerprints).and_return(['pubfp1', 'pubfp2'])
      allow(runner).to receive(:delete_public_key) { |k| deleted_fingerprints << k }

      engine.delete_all_keys

      expect(deleted_fingerprints).to eq(['privfp1', 'privfp2', 'pubfp1', 'pubfp2'])
    end
  end

  describe :import_key do
    it 'creates a temporary file and imports the key' do
      setup_valid_gpg_version
      temp_file_stub = setup_temp_file('key contents aaaaa')
      allow(runner).to receive(:import_key_from_file).with(temp_file_stub.path).and_return([
        'email1@gmail.com',
        'email2@gmail.com'
      ])

      expect(engine.import_key('key contents aaaaa')).to eq(['email1@gmail.com', 'email2@gmail.com'])

      expect(temp_file_stub).to have_received(:write)
      expect(temp_file_stub).to have_received(:rewind)
      expect(runner).to have_received(:import_key_from_file)
    end

    it 'fails when gpg is not correctly installed' do
      setup_invalid_gpg_version

      expect{
        engine.import_key('aaaaaaaaaa')
      }.to raise_exception('GPG Version is incorrect')
    end
  end

  describe :verify_signature do
    it 'verifies the signature using the pgp runner' do
      setup_temp_paths(['path2', 'path1'])
      allow(File).to receive(:write).with('path1', 'signature contents')
      allow(File).to receive(:read).with('path2').and_return('secret plain')
      allow(runner).to receive(:verify_signature_file)
                           .with('path1', 'path2')
                           .and_return(true)

      expect(engine.verify_signature('signature contents')).to eq([true, 'secret plain'])

      expect(runner).to have_received(:verify_signature_file)
      expect(File).to have_received(:write)
      expect(File).to have_received(:read)
    end

    it 'returns no data when verification failed' do
      setup_temp_paths(['path2', 'path1'])
      allow(File).to receive(:write)
      allow(runner).to receive(:verify_signature_file).and_return(false)

      expect(engine.verify_signature('signature contents')).to eq([false, ''])
    end
  end

  describe :decrypt do
    it 'decrypts the data with a passphrase' do
      setup_temp_paths(['path2', 'path1'])
      allow(File).to receive(:write).with('path1', 'encrypted message')
      allow(File).to receive(:read).with('path2').and_return('the answer is 42')
      allow(runner).to receive(:decrypt_file)
                           .with('path1', 'path2', 'supersecret')
                           .and_return(true)

      expect(engine.decrypt('encrypted message', 'supersecret')).to eq([true, 'the answer is 42'])

      expect(runner).to have_received(:decrypt_file)
      expect(File).to have_received(:write)
      expect(File).to have_received(:read)
    end

    it 'returns no data when decryption failed' do
      setup_temp_paths(['path2', 'path1'])
      allow(File).to receive(:write)
      allow(runner).to receive(:decrypt_file).and_return(false)

      expect(engine.decrypt('encrypted text')).to eq([false, ''])
    end
  end

  describe :encrypt do
    it 'encrypts the data' do
      setup_temp_paths(['path2', 'path1'])
      allow(File).to receive(:write).with('path1', 'plain text message')
      allow(File).to receive(:read).with('path2').and_return('encrypted text')
      allow(runner).to receive(:encrypt_file)
                           .with('path1', 'path2', ['email1@gmail.com', 'email2@gmail.com'])
                           .and_return(true)

      expect(engine.encrypt('plain text message', ['email1@gmail.com', 'email2@gmail.com'])).to eq([true, 'encrypted text'])

      expect(runner).to have_received(:encrypt_file)
      expect(File).to have_received(:write)
      expect(File).to have_received(:read)
    end

    it 'raises an error when the recipient parameters are empty' do
      expect {
        engine.encrypt('some text', [])
      }.to raise_exception 'Recipients cannot be empty'
    end

    it 'returns no data when encryption failed' do
      setup_temp_paths(['path2', 'path1'])
      allow(File).to receive(:write)
      allow(runner).to receive(:encrypt_file).and_return(false)

      expect(engine.encrypt('some text', ['aaa@gmail.com'])).to eq([false, ''])
    end
  end

  describe :sign do
    it 'signs the data with a passphrase' do
      setup_temp_paths(['path2', 'path1'])
      allow(File).to receive(:write).with('path1', 'plain text message')
      allow(File).to receive(:read).with('path2').and_return('encrypted signature')
      allow(runner).to receive(:sign_file)
                           .with('path1', 'path2', 'supersecret')
                           .and_return(true)

      expect(engine.sign('plain text message', 'supersecret')).to eq([true, 'encrypted signature'])

      expect(runner).to have_received(:sign_file)
      expect(File).to have_received(:write)
      expect(File).to have_received(:read)
    end

    it 'returns no data when signing failed' do
      setup_temp_paths(['path2', 'path1'])
      allow(File).to receive(:write)
      allow(runner).to receive(:sign_file).and_return(false)

      expect(engine.sign('something')).to eq([false, ''])
    end
  end

  describe :read_recipients do
    it 'merges the private and public recipients' do
      allow(runner).to receive(:read_public_key_recipients).and_return([
        'email1@gmail.com',
        'email1@gmail.com',
        'email2@gmail.com',
        'email3@gmail.com'
      ])
      allow(runner).to receive(:read_private_key_recipients).and_return([
        'email3@gmail.com',
        'email4@gmail.com'
      ])

      expect(engine.read_recipients).to eq([
        'email1@gmail.com',
        'email2@gmail.com',
        'email3@gmail.com',
        'email4@gmail.com'
      ])
    end
  end
end