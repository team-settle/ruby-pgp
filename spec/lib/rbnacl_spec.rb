require 'spec_helper'
require 'rbnacl'

describe 'rbnacl' do
  it 'can verify a file with the correct key' do
    expected_contents = File.read(Fixtures_Path.join('signed_file.txt'))
    signed_data = File.read(Fixtures_Path.join('signed_file.txt.asc'))

    public_key = File.read(Fixtures_Path.join('public_key_with_passphrase.asc').to_s)
    verifier = RbNaCl::VerifyKey.new(public_key).verify_key

    value = verifier.verify(signed_data, expected_contents)
    expect(value).to eq(true)
  end
end