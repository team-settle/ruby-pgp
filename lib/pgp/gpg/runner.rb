require 'open3'

module GPG
  class Runner
    attr_accessor :verbose

    def initialize(verbose = false)
      self.verbose = verbose
    end

    def version_default
      read_version('gpg --version', '')
    end

    def read_private_key_fingerprints
      run('gpg --quiet --list-secret-keys --fingerprint') do |stdin, output, handle|
        return [] unless handle.value.success?
        extract_fingerprints(output.gets)
      end
    end

    def read_public_key_fingerprints
      run('gpg --quiet --list-keys --fingerprint') do |stdin, output, handle|
        return [] unless handle.value.success?
        extract_fingerprints(output.gets)
      end
    end

    def delete_private_key(fingerprint)
      run_gpg_silent_command("gpg --quiet --batch --delete-secret-key #{fingerprint}")
    end

    def delete_public_key(fingerprint)
      run_gpg_silent_command("gpg --quiet --batch --delete-key #{fingerprint}")
    end

    def import_key_from_file(path)
      log("Import Key; path: #{path}; contents:\n#{File.read(path)}")
      run_gpg_silent_command("gpg --quiet --batch --import \"#{path}\"")
    end

    def verify_signature_file(path, data_output_path=nil)
      if data_output_path.nil?
        log("Verify Signature; path: #{path}; contents:\n#{File.read(path)}")
        run_gpg_silent_command("gpg --quiet --batch --verify \"#{path}\"")
      else
        log("Verify Signature; path: #{path}; data_output_path: #{data_output_path}; contents:\n#{File.read(path)}")
        run_gpg_silent_command("gpg --quiet --batch --output \"#{data_output_path}\" \"#{path}\"")
      end
    end

    private

    def run_gpg_silent_command(command)
      run(command) do |stdin, output, handle|
        handle.value.success?
      end
    end

    def read_version(command, default_value)
      run(command) do |stdin, output, handle|
        return default_value unless handle.value.success?
        output.gets.lines.first.split(' ').last.strip
      end
    end

    def extract_fingerprints(str)
      (str || '')
          .lines
          .filter { |l| l.downcase.include? 'key fingerprint =' }
          .map { |l| l.split('=').last }
          .map { |l| l.gsub(' ', '').strip }
    end

    def run(command)
      log("Running Command: #{command}")

      Open3.popen2e(command) do |stdin, output, handle|
        log("Output:\n#{output.gets}")
        log("Success?: #{handle.value.success?}")

        yield(stdin, output, handle)
      end
    end

    def log(message)
      if verbose
        PGP::Log.logger.info(message)
      end
    end
  end
end