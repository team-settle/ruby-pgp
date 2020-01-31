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
      temp_file_stub = setup_temp_file('key contents aaaaa')
      allow(runner).to receive(:import_key_from_file).with(temp_file_stub.path).and_return(true)

      expect(engine.import_key('key contents aaaaa')).to eq(true)

      expect(temp_file_stub).to have_received(:write)
      expect(temp_file_stub).to have_received(:rewind)
      expect(runner).to have_received(:import_key_from_file)
    end
  end

  describe :verify_signature do
    let(:path1) { random_string }
    let(:path2) { random_string }
    let(:stub) { double }

    before {
      allow(stub).to receive(:path).and_return(path1, path2)
      allow(stub).to receive(:rewind)

      allow(Tempfile).to receive(:open).and_yield(stub)
    }

    it 'creates a temporary file and verifies the signature data' do
      allow(stub).to receive(:write).with('signature contents aaaaa')
      allow(stub).to receive(:read).and_return('signed data')

      allow(runner).to receive(:verify_signature_file)
                           .with(path1, path2)
                           .and_return(true)

      expect(engine.verify_signature('signature contents aaaaa')).to eq([true, 'signed data'])

      expect(stub).to have_received(:write)
      expect(stub).to have_received(:rewind).twice
      expect(stub).to have_received(:read)
      expect(runner).to have_received(:verify_signature_file)
    end

    it 'returns no data when verification failed' do
      allow(stub).to receive(:write)
      allow(runner).to receive(:verify_signature_file).and_return(false)

      expect(engine.verify_signature('signature contents')).to eq([false, ''])
    end
  end
end