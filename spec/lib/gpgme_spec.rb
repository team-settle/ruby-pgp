require 'spec_helper'
require 'gpgme'

describe 'gpgme' do
  def remove_all_keys
    GPGME::Key.find(:public).each do |k|
      k.delete!(true)
    end
    GPGME::Key.find(:secret).each do |k|
      k.delete!(true)
    end
  end

  before {
    remove_all_keys
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
end