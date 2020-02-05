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
end