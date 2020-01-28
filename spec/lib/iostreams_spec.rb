require 'spec_helper'
require 'iostreams'

describe 'iostreams' do
  it 'can verify a file with the correct public key' do
    signed_data = File.read(Fixtures_Path.join('signed_file.txt.asc'))

    IOStreams::Pgp.delete_keys(email: nil, private: false)
    IOStreams::Pgp.delete_keys(email: nil, private: true)

    IOStreams.reader(StringIO.new(signed_data)) do |stream|
     while data = stream.read(10)
       p data
     end
    end
  end
end