require 'tempfile'
require 'tmpdir'

module GPG
  class Engine
    attr_accessor :runner
    attr_accessor :verbose

    def initialize(runner = nil, verbose = true)
      self.runner = runner || GPG::Runner.new
      self.verbose = verbose
      self.runner.verbose = self.verbose
    end

    def import_key(key_contents)
      log("Import Key")
      Tempfile.open do |f|
        f.write(key_contents)
        f.rewind
        runner.import_key_from_file(f.path)
      end
    end

    def verify_signature(signature_data)
      log("Verify Signature")
      signature_path = File.join(Dir.tmpdir, random_string)
      output_path = File.join(Dir.tmpdir, random_string)
      File.delete(output_path) if File.exists?(output_path)

      File.write(signature_path, signature_data)
      verification = runner.verify_signature_file(signature_path, output_path)
      data = ''
      if verification
        data = File.read(output_path)
      end

      File.delete(output_path) if File.exists?(output_path)
      File.delete(signature_path) if File.exists?(signature_path)

      [verification, data]
    end

    def delete_all_keys
      delete_all_private_keys
      delete_all_public_keys
    end

    def delete_all_private_keys
      log('Delete all private keys')
      runner.read_private_key_fingerprints.each do |k|
        runner.delete_private_key k
      end
    end

    def delete_all_public_keys
      log('Delete all public keys')
      runner.read_public_key_fingerprints.each do |k|
        runner.delete_public_key k
      end
    end

    protected

    def log(message)
      if verbose
        PGP::Log.logger.info(message)
      end
    end

    def random_string(length=20)
      (0...length).map { (65 + rand(26)).chr }.join
    end
  end
end