module PGP
  module KeysImporter
    def add_keys(key_string)
      GPG::Engine.new.import_key(key_string)
    end

    def add_keys_from_file(filename)
      add_keys(File.read(filename))
    end
  end
end