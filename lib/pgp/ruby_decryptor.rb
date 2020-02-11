module PGP
  class RubyDecryptor
    def self.decrypt(encrypted_text, private_key_file, passphrase=nil)
      engine = GPG::Engine.new
      engine.import_key(File.read(private_key_file))
      engine.decrypt(encrypted_text, passphrase)[1]
    end
  end
end
