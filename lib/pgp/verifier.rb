require 'gpgme'

module PGP
  class Verifier
    def add_keys(key_string)
      GPGME::VersionHelper.switch_to_gpg1
      GPGME::Key.import(key_string)
    end

    def add_keys_from_file(filename)
      add_keys(File.read(filename))
    end

    def verify(signed_data)
      GPGME::VersionHelper.switch_to_gpg1
      crypto = GPGME::Crypto.new
      output_data = GPGME::Data.empty!

      signature_valid = false
      crypto.verify(signed_data, output: output_data) do |signature|
        signature_valid = signature.valid?
      end

      raise 'Signature could not be verified' unless signature_valid

      output_data.to_s
    end
  end
end