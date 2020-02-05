require 'tmpdir'

module PGP
  class Verifier
    include PGP::KeysImporter

    def verify(signed_data)
      result = GPG::Engine.new.verify_signature(signed_data)
      signature_valid = result[0]

      raise 'Signature could not be verified' unless signature_valid

      result[1]
    end
  end
end