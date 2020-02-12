module PGP
  class Encryptor
    attr_accessor :recipients

    def initialize(key_string=nil)
      self.recipients = []
      add_keys(key_string) if key_string
    end

    def add_keys(key_string)
      self.recipients += GPG::Engine.new.import_key(key_string)
    end

    def add_keys_from_file(filename)
      add_keys(File.read(filename))
    end

    def encrypt(cleartext, filename=nil, mtime=nil)
      result = GPG::Engine.new.encrypt(cleartext, recipients)

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
