module PGP
  class Verifier
    def verify(signed_data)
      result = GPG::Engine.new.verify_signature(signed_data)
      signature_valid = result[0]

      raise 'Signature could not be verified' unless signature_valid

      result[1]
    end

    def add_keys(key_string)
      GPG::Engine.new.import_key(key_string)
    end

    def add_keys_from_file(filename)
      add_keys(File.read(filename))
    end
  end
end