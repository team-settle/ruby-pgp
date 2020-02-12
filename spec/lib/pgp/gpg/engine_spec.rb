require 'spec_helper'

describe GPG::Engine do
  include TempHelper

  let(:engine) { GPG::Engine.new }
  let(:runner) { engine.runner }

  describe :delete_all_private_keys do
    it 'deletes all the private keys' do
      allow(runner).to receive(:read_private_key_fingerprints).and_return(['fp1', 'fp2'])
      allow(runner).to receive(:delete_private_key)

      engine.delete_all_private_keys

      expect(runner).to have_received(:delete_private_key).with('fp1')
      expect(runner).to have_received(:delete_private_key).with('fp2')
    end
  end

  describe :delete_all_public_keys do
    it 'deletes all the public keys' do
      allow(runner).to receive(:read_public_key_fingerprints).and_return(['fp1', 'fp2'])
      allow(runner).to receive(:delete_public_key)

      engine.delete_all_public_keys

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

      engine.delete_all_keys

      expect(deleted_fingerprints).to eq(['privfp1', 'privfp2', 'pubfp1', 'pubfp2'])
    end
  end

  describe :import_key do
    it 'creates a temporary file and imports the key' do
      allow(engine).to receive(:read_recipients).and_return(
          ['aaa@gmail.com'],
          ['aaa@gmail.com', 'bbb@gmail.com', 'ccc@gmail.com']
      )

      temp_file_stub = setup_temp_file('key contents aaaaa')
      allow(runner).to receive(:import_key_from_file).with(temp_file_stub.path).and_return(true)

      expect(engine.import_key('key contents aaaaa')).to eq(['bbb@gmail.com', 'ccc@gmail.com'])

      expect(temp_file_stub).to have_received(:write)
      expect(temp_file_stub).to have_received(:rewind)
      expect(runner).to have_received(:import_key_from_file)
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
    it 'decrypts the data without passphrase' do
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