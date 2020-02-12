module PGP
  class Signer
    include PGP::KeysImporter

    attr_accessor :passphrase

    def sign(data)
      result = GPG::Engine.new.sign(data, self.passphrase)
      result[1]
    end

    def sign_file(file_path)
      sign File.read(file_path)
    end
  end
end