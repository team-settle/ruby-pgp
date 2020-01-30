module PGP
  class Verifier
    include PGP::KeysImporter

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