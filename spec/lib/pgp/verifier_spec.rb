require 'spec_helper'

describe PGP::Verifier do
  include KeysHelper

  let(:verifier) { PGP::Verifier.new }
  let(:unsigned_file) { Fixtures_Path.join('signed_file.txt') }
  let(:signed_file) { Fixtures_Path.join('signed_file.txt.asc') }

  before { remove_all_keys }

  describe '#verify' do
    context 'When the Public Key is from a file' do
      let(:public_key_path) { Fixtures_Path.join('public_key_with_passphrase.asc').to_s }

      before do
        verifier.add_keys_from_file(public_key_path)
      end

      it "verifies" do
        expect(verifier.verify(File.read(signed_file))).to eq(File.read(unsigned_file))
      end
    end

    context 'When the public key cannot verify a signature' do
      let(:public_key_path_wrong_public_key) { Fixtures_Path.join('wrong_public_key_for_signature.asc').to_s }

      before do
        verifier.add_keys_from_file(public_key_path_wrong_public_key)
      end

      it "should raise an exception" do
        expect {
          verifier.verify(File.read(signed_file))
        }.to raise_exception 'Signature could not be verified'
      end
    end
  end

end
