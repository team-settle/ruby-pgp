module PGP
  module KeysImporter
    def add_keys(key_string)
      GPGME::VersionHelper.switch_to_gpg1
      GPGME::Key.import(key_string)
    end

    def add_keys_from_file(filename)
      add_keys(File.read(filename))
    end
  end
end