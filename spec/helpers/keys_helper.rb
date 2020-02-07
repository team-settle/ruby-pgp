module KeysHelper
  def remove_all_keys
    gpg = GPG::Engine.new
    gpg.delete_all_keys

    raise 'No public keys expected' unless gpg.runner.read_public_key_fingerprints.empty?
    raise 'No private keys expected' unless gpg.runner.read_private_key_fingerprints.empty?
  end
end