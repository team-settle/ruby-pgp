require 'pgp/log'
require 'pgp/decryptor'
require 'pgp/encryptor'
require 'pgp/verifier'
require 'pgp/signer'
require 'pgp/gpg/temp_path_helper'
require 'pgp/gpg/runner'
require 'pgp/gpg/engine'

module PGP
  autoload :VERSION,        'pgp/version'
  autoload :RubyDecryptor,  'pgp/ruby_decryptor'
  autoload :CLI,            'pgp/cli'

  # This exists for stubbing during tests
  def self.time_now
    Time.now
  end
end
