require 'spec_helper'

describe GPG::Runner do
  include KeysHelper

  let(:runner) { GPG::Runner.new(verbose: true) }

  before { remove_all_keys }

  it 'has no keys by default' do
    expect(runner.read_private_key_fingerprints).to eq([])
    expect(runner.read_public_key_fingerprints).to eq([])
  end

  it 'uses GPG version 2' do
    expect(runner.version_default).to include('2.')
  end

  it 'imports private keys' do
    runner.import_key_from_file(Fixtures_Path.join('private_key.asc'))

    expect(runner.read_private_key_fingerprints).to eq(['A99BFCC3B6B952D66AFC1F3C48508D311DD34131'])
  end

  it 'imports public keys' do
    runner.import_key_from_file(Fixtures_Path.join('public_key.asc'))

    expect(runner.read_public_key_fingerprints).to eq(['A99BFCC3B6B952D66AFC1F3C48508D311DD34131'])
  end
end