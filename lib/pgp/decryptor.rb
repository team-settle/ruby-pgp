module PGP
  class Decryptor
    include PGP::KeysImporter

    attr_accessor :passphrase

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
