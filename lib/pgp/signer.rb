module PGP
  class Signer
    attr_accessor :passphrase

    def sign(data)
      result = GPG::Engine.new.sign(data, self.passphrase)
      result[1]
    end

    def sign_file(file_path)
      sign File.read(file_path)
    end

    def add_keys(key_string)
      GPG::Engine.new.import_key(key_string)
    end

    def add_keys_from_file(filename)
      add_keys(File.read(filename))
    end
  end
end