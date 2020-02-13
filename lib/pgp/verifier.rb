module PGP
  class Verifier
    def initialize
      @gpg_engine = GPG::Engine.new
    end

    def verify(signed_data)
      result = @gpg_engine.verify_signature(signed_data)
      signature_valid = result[0]

      raise 'Signature could not be verified' unless signature_valid

      result[1]
    end

    def add_keys(key_string)
      @gpg_engine.import_key(key_string)
    end

    def add_keys_from_file(filename)
      add_keys(File.read(filename))
    end
  end
end