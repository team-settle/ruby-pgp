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

  #before {
  #  remove_all_keys
  #}

  it 'can verify a file' do
    expected_contents = File.read(Fixtures_Path.join('signed_file.txt'))
    #p expected_contents
    #p '----------------------------------------------------------------'

    #signed_data = GPGME::Data.from_str(File.read(Fixtures_Path.join('signed_file.txt.asc')))
    signed_data = File.read(Fixtures_Path.join('signed_file.txt.asc'))
    #p signed_data
    #p '----------------------------------------------------------------'

    GPGME::Key.import(File.open(Fixtures_Path.join('public_key_with_passphrase.asc').to_s))

    crypto = GPGME::Crypto.new
    signatures = 0
    crypto.verify(signed_data) do |signature|
      #p signature
      #p '----------------------------------------------------------------'
      expect(signature.valid?).to eq(true)
      signatures += 1
    end
    expect(signatures).to eq(1)

    #output_data = GPGME::Data.empty!
    #crypto.verify(signed_data, output: output_data) do |signature|
    #  expect(signature.valid?).to eq(true)
    #end
    #actual_contents = output_data.to_s
    #expect(actual_contents).to eq(expected_contents)
  end
end