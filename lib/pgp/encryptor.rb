module PGP
  class Encryptor
    attr_accessor :recipients

    def initialize(key_string=nil, gpg_engine=nil)
      @gpg_engine = gpg_engine || GPG::Engine.new
      self.recipients = []
      add_keys(key_string) if key_string
    end

    def add_keys(key_string)
      self.recipients += @gpg_engine.import_key(key_string)
    end

    def add_keys_from_file(filename)
      add_keys(File.read(filename))
    end

    def encrypt(cleartext, filename: nil, options: [])
      result = @gpg_engine.encrypt(cleartext, recipients, options)

      unless filename.nil?
        File.write(filename, result[1])
      end

      result[1]
    end

    def encrypt_file(file_path)
      encrypt(File.read(file_path))
    end

  end
end
