require 'spec_helper'

describe GPG::Engine do
  let(:runner) { double }
  let(:engine) { GPG::Engine.new(runner) }

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
      temp_file_stub = double
      allow(temp_file_stub).to receive(:path).and_return('/tmp/zzz1')
      allow(temp_file_stub).to receive(:write).with('key contents aaaaa')
      allow(Tempfile).to receive(:open).and_yield(temp_file_stub)
      allow(runner).to receive(:import_key_from_file).with('/tmp/zzz1').and_return(true)

      expect(engine.import_key('key contents aaaaa')).to eq(true)

      expect(temp_file_stub).to have_received(:write)
      expect(runner).to have_received(:import_key_from_file)
    end
  end
end