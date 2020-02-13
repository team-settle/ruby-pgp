module PGP
  class Decryptor
    attr_accessor :passphrase

    def initialize(gpg_engine=nil)
      @gpg_engine = gpg_engine || GPG::Engine.new
    end

    def decrypt(encrypted_data)
      result = @gpg_engine.decrypt(encrypted_data, self.passphrase)
      result[1]
    end

    def decrypt_file(file_path)
      decrypt File.read(file_path)
    end

    def add_keys(key_string)
      @gpg_engine.import_key(key_string)
    end

    def add_keys_from_file(filename)
      add_keys(File.read(filename))
    end
  end
end
