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

  it 'can verify a file' do
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
end