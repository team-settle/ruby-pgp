require 'open3'

module GPG
  class Runner
    attr_accessor :verbose

    def initialize(verbose = false)
      self.verbose = verbose
    end

    def version_default
      read_version('gpg2 --version', '')
    end

    def read_private_key_fingerprints
      run('gpg2 --quiet --list-secret-keys --fingerprint') do |stdin, output, handle|
        return [] unless handle.value.success?
        extract_fingerprints(output)
      end
    end

    def read_public_key_fingerprints
      run('gpg2 --quiet --list-keys --fingerprint') do |stdin, output, handle|
        return [] unless handle.value.success?
        extract_fingerprints(output)
      end
    end

    def delete_private_key(fingerprint)
      run_gpg_silent_command("gpg2 --quiet --batch --delete-secret-key #{fingerprint}")
    end

    def delete_public_key(fingerprint)
      run_gpg_silent_command("gpg2 --quiet --batch --delete-key #{fingerprint}")
    end

    def import_key_from_file(path)
      log("Import Key; path: #{path}; contents:\n#{File.read(path)}")
      run_gpg_silent_command("gpg2 --quiet --batch --import \"#{path}\"")
    end

    def verify_signature_file(path, data_output_path=nil)
      if data_output_path.nil?
        log("Verify Signature; path: #{path}; contents:\n#{File.read(path)}")
        run_gpg_silent_command("gpg2 --quiet --batch --verify \"#{path}\"")
      else
        log("Verify Signature; path: #{path}; data_output_path: #{data_output_path}; contents:\n#{File.read(path)}")
        run_gpg_silent_command("gpg2 --quiet --batch --output \"#{data_output_path}\" \"#{path}\"")
      end
    end

    def decrypt_file(path, data_output_path, passphrase=nil)
      passphrase ||= ''

      if passphrase.empty?
        run_gpg_silent_command("gpg2 --quiet --batch --yes --ignore-mdc-error --output \"#{data_output_path}\" --decrypt \"#{path}\"")
      else
        if version_default.start_with?('2.0.')
          run_gpg_silent_command("gpg2 --quiet --batch --passphrase \"#{passphrase}\" --yes --ignore-mdc-error --output \"#{data_output_path}\" --decrypt \"#{path}\"")
        else
          run_gpg_silent_command("gpg2 --quiet --batch --pinentry-mode loopback --passphrase \"#{passphrase}\" --yes --ignore-mdc-error --output \"#{data_output_path}\" --decrypt \"#{path}\"")
        end
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
        output.lines.first.split(' ').last.strip
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
        output_data = stream_to_string(output)

        log("Output:\n#{output_data}")
        log("Success?: #{handle.value.success?}")

        yield(stdin, output_data, handle)
      end
    end

    def stream_to_string(stream)
      result = ''
      loop do
        data = stream.gets

        if data.nil?
          break
        end

        result << data
      end
      result
    end

    def log(message)
      if verbose
        PGP::Log.logger.info(message)
      end
    end
  end
end