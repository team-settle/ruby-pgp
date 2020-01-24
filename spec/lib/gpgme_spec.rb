require 'spec_helper'
require 'gpgme'
require 'pgp/passphrase_callback'

describe 'gpgme' do
  it 'can verify a file' do
    expected_contents = File.read(Fixtures_Path.join('signed_file.txt'))

    #signed_data = GPGME::Data.from_str(File.read(Fixtures_Path.join('signed_file.txt.asc')))
    signed_data = File.read(Fixtures_Path.join('signed_file.txt.asc'))

    #expect(1).to eq(2)

    crypto = GPGME::Crypto.new
    #signatures = 0
    #crypto.verify(signed_data) do |signature|
    #  expect(signature.valid?).to eq(true)
    #  signatures += 1
    #end
    #expect(signatures).to eq(1)

    output_data = GPGME::Data.empty!
    crypto.verify(signed_data, output: output_data) do |signature|
      expect(signature.valid?).to eq(true)
    end
    actual_contents = output_data.to_s
    expect(actual_contents).to eq(expected_contents)
  end
end