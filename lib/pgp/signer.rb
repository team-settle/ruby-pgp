module PGP
  class Signer
    attr_accessor :passphrase

    def initialize(gpg_engine=nil)
      @gpg_engine = gpg_engine || GPG::Engine.new
    end

    def sign(data)
      result = @gpg_engine.sign(data, self.passphrase)
      result[1]
    end

    def sign_file(file_path)
      sign File.read(file_path)
    end

    def add_keys(key_string)
      @gpg_engine.import_key(key_string)
    end

    def add_keys_from_file(filename)
      add_keys(File.read(filename))
    end
  end
end