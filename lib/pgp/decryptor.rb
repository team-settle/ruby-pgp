module PGP
  class Decryptor
    attr_accessor :passphrase

    def add_keys(key_string)
      GPGME::VersionHelper.switch_to_gpg1
      GPGME::Key.import(key_string)
    end

    def add_keys_from_file(filename)
      add_keys(File.read(filename))
    end

    def decrypt(encrypted_data)
      GPGME::VersionHelper.switch_to_gpg1
      crypto = GPGME::Crypto.new({ pinentry_mode: GPGME::PINENTRY_MODE_LOOPBACK })
      crypto.decrypt(encrypted_data, decrypt_options).to_s
    end

    def decrypt_file(file_path)
      decrypt File.read(file_path)
    end

    protected

    def decrypt_options
      if (passphrase || '').empty?
        {}
      else
        { password: passphrase }
      end
    end
  end
end
