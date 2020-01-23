module PGP
  # This is more module than class. Eventually it will probably inherit from
  #   the PGPPrivateKey class and make using it less ghoulish.
  class PrivateKey
    include_package "org.bouncycastle.openpgp"
    include_package "org.bouncycastle.openpgp.operator.bc"
    include_package "org.bouncycastle.openpgp.operator.jcajce"
    include_package "java.security"

    def self.from_string(string, key_id)
      stream = PGP.string_to_bais(string)
      pgp_sec = keyring_from_stream(stream)
      sec_key = pgp_sec.get_secret_key(key_id)

      return extract_private_key(sec_key) if sec_key
    end

    def self.from_file(filename, key_id)
      pgp_sec = keyring_from_file(filename)
      sec_key = pgp_sec.get_secret_key(key_id)

      return extract_private_key(sec_key) if sec_key
    end

    def self.keyring_from_file(filename)
      file = File.open(filename)
      keyring_from_stream(file.to_inputstream)
    end

    def self.keyring_from_stream(stream)
      yafs = PGPUtil.get_decoder_stream(stream)
      fingerprint_calculator = BcKeyFingerprintCalculator.new()
      PGPSecretKeyRingCollection.new(yafs, fingerprint_calculator)
    end

    def self.extract_private_key(sec_key)
      if sec_key
        passphrase = nil
        provider = Security.getProvider(BC_Provider_Code)
        decryptor_factory = JcePBESecretKeyDecryptorBuilder.new(
            JcaPGPDigestCalculatorProviderBuilder.new().set_provider(provider).build()
        ).set_provider(provider).build(passphrase)

        sec_key.extract_private_key(decryptor_factory)
      else
        nil
      end
    end
  end
end
