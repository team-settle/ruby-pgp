module PGP
  class Decryptor
    include PGP::KeysImporter

    attr_accessor :passphrase

    def decrypt(encrypted_data)
      result = GPG::Engine.new.decrypt(encrypted_data, self.passphrase)
      result[1]
    end

    def decrypt_file(file_path)
      decrypt File.read(file_path)
    end
  end
end
