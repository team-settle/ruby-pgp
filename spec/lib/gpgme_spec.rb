require 'spec_helper'
require 'gpgme'

describe 'gpgme' do
  include KeysHelper

  before {
    remove_all_keys

    runner = GPG::Runner.new
    if runner.should_switch_to_gpg1?
      bin = runner.binary_path_gpg1
      home_dir = GPGME::Engine.dirinfo('homedir')
      GPGME::Engine.set_info(GPGME::PROTOCOL_OpenPGP, bin, home_dir)
    end
  }

  it 'can verify a file with the correct key' do
    expected_contents = File.read(Fixtures_Path.join('signed_file.txt'))
    signed_data = File.read(Fixtures_Path.join('signed_file.txt.asc'))

    GPGME::Key.import(File.open(Fixtures_Path.join('public_key_with_passphrase.asc').to_s))

    crypto = GPGME::Crypto.new
    output_data = GPGME::Data.empty!
    crypto.verify(signed_data, output: output_data) do |signature|
      expect(signature.valid?).to eq(true)
    end
    expect(output_data.to_s).to eq(expected_contents)
  end

  it 'cannot verify a file with the incorrect key' do
    signed_data = File.read(Fixtures_Path.join('signed_file.txt.asc'))

    GPGME::Key.import(File.open(Fixtures_Path.join('wrong_public_key_for_signature.asc').to_s))

    crypto = GPGME::Crypto.new
    output_data = GPGME::Data.empty!

    signature_valid = nil
    crypto.verify(signed_data, output: output_data) do |signature|
      signature_valid = signature.valid?
    end

    expect(signature_valid).to eq(false)
  end

  it 'can decrypt a file with a private key' do
    unencrypted_text = File.read(Fixtures_Path.join('unencrypted_file.txt'))

    GPGME::Key.import(File.open(Fixtures_Path.join('private_key.asc').to_s))
    crypto = GPGME::Crypto.new
    actual = crypto.decrypt(File.read(Fixtures_Path.join('unencrypted_file.txt.asc'))).to_s
    expect(actual).to eq(unencrypted_text)
  end

  it 'can decrypt a file with a private key with passphrase' do
    unencrypted_text = File.read(Fixtures_Path.join('encrypted_with_passphrase_key.txt'))

    GPGME::Key.import(File.open(Fixtures_Path.join('private_key_with_passphrase.asc').to_s))
    crypto = GPGME::Crypto.new({ pinentry_mode: GPGME::PINENTRY_MODE_LOOPBACK })
    actual = crypto.decrypt(
        File.read(Fixtures_Path.join('encrypted_with_passphrase_key.txt.asc')),
        { password: 'testingpgp' }
    ).to_s
    expect(actual).to eq(unencrypted_text)
  end
end