module PGP
  class Decryptor
    attr_accessor :passphrase

    def decrypt(encrypted_data)
      result = GPG::Engine.new.decrypt(encrypted_data, self.passphrase)
      result[1]
    end

    def decrypt_file(file_path)
      decrypt File.read(file_path)
    end

    def add_keys(key_string)
      GPG::Engine.new.import_key(key_string)
    end

    def add_keys_from_file(filename)
      add_keys(File.read(filename))
    end
  end
end
