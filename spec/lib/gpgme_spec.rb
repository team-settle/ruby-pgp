require 'spec_helper'
require 'gpgme'

describe 'gpgme' do
  let(:private_key_path) { Fixtures_Path.join('private_key_with_passphrase.asc').to_s }
  let(:public_key_path) { Fixtures_Path.join('public_key_with_passphrase.asc').to_s }
  let(:passphrase) { 'testingpgp' }
  let(:unsigned_file) { Fixtures_Path.join('signed_file.txt') }
  let(:signed_file) { Fixtures_Path.join('signed_file.txt.asc') }

  it 'can sign a file' do
    unsigned_data_str = File.read(unsigned_file)
    private_key_data_str = File.read(private_key_path)
    expected_signed_data_str = File.read(signed_file)

    private_key_data = GPGME::Data.from_str(private_key_data_str)
    unsigned_data = GPGME::Data.from_str(unsigned_data_str)

    signed_data = GPGME::Data.new
    GPGME::Ctx.new(password: passphrase) do |ctx|
      ctx.import_keys(private_key_data)
      ctx.sign(unsigned_data, signed_data, GPGME::SIG_MODE_CLEAR)
    end

    actual_signed_data_str = signed_data.to_s
    expect(actual_signed_data_str).to eq(expected_signed_data_str)
  end
end