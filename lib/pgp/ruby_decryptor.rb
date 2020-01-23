module PGP
  class RubyDecryptor
    include_package "org.bouncycastle.openpgp"
    include_package "org.bouncycastle.openpgp.operator.bc"
    include_package "org.bouncycastle.openpgp.operator.jcajce"
    include_package "java.security"

    java_import 'java.io.ByteArrayOutputStream'

    def self.decrypt(encrypted_text, private_key_file)
      bytes = PGP.string_to_bais(encrypted_text)
      dec_s = PGPUtil.get_decoder_stream(bytes)
      fingerprint_calculator = BcKeyFingerprintCalculator.new()
      pgp_f = PGPObjectFactory.new(dec_s, fingerprint_calculator)

      enc_data = pgp_f.next_object
      enc_data = pgp_f.next_object unless PGPEncryptedDataList === enc_data

      data_enumerator = enc_data.get_encrypted_data_objects

      sec_key = nil
      pbe     = nil

      data_enumerator.each do |pubkey_enc_data|
        pbe     = pubkey_enc_data
        key_id  = pubkey_enc_data.get_key_id
        sec_key = PrivateKey.from_file(private_key_file, key_id)

        if sec_key.nil?
          # @todo: Should we notify Airbrake?
          Ace.logger.debug "This may be cause for concern. The data being decrypted has a key_id of '#{key_id}', which can not be found in the private key file '#{CE_Private_Key}'."
        else
          break
        end
      end

      provider = Security.get_provider(BC_Provider_Code)
      factory = JcePublicKeyDataDecryptorFactoryBuilder.new().set_provider(provider).set_content_provider(provider).build(sec_key)
      clear = pbe.get_data_stream(factory)

      fingerprint_calculator = BcKeyFingerprintCalculator.new()

      plain_fact = PGPObjectFactory.new(clear, fingerprint_calculator)

      message = plain_fact.next_object

      if(PGPCompressedData === message)
        fingerprint_calculator = BcKeyFingerprintCalculator.new()
        pgp_fact  = PGPObjectFactory.new(message.get_data_stream, fingerprint_calculator)
        message   = pgp_fact.next_object
      end

      baos = ByteArrayOutputStream.new

      if(PGPLiteralData === message)
        unc = message.get_input_stream
        while((ch = unc.read) >= 0)
          baos.write(ch)
        end
      end

      baos.to_string
    end


  end
end
