require 'open3'

module GPG
  class Runner
    include PGP::LogCapable

    attr_accessor :version_cache

    def version_default
      if self.version_cache.nil?
        self.version_cache = read_version('gpg --version', '')
      end

      self.version_cache
    end

    def read_private_key_recipients
      run('gpg --quiet --list-secret-keys --fingerprint --keyid-format LONG') do |stdin, output, handle|
        return [] unless handle.value.success?
        extract_recipients(output)
      end
    end

    def read_public_key_recipients
      run('gpg --quiet --list-keys --fingerprint --keyid-format LONG') do |stdin, output, handle|
        return [] unless handle.value.success?
        extract_recipients(output)
      end
    end

    def read_private_key_fingerprints
      run('gpg --quiet --list-secret-keys --fingerprint --keyid-format LONG') do |stdin, output, handle|
        return [] unless handle.value.success?
        extract_fingerprints(output)
      end
    end

    def read_public_key_fingerprints
      run('gpg --quiet --list-keys --fingerprint --keyid-format LONG') do |stdin, output, handle|
        return [] unless handle.value.success?
        extract_fingerprints(output)
      end
    end

    def delete_private_key(fingerprint)
      run_gpg_silent_command("gpg --quiet --batch --yes --delete-secret-key #{fingerprint}")
    end

    def delete_public_key(fingerprint)
      run_gpg_silent_command("gpg --quiet --batch --yes --delete-key #{fingerprint}")
    end

    def import_key_from_file(path)
      log("Import Key; path: #{path}; contents:\n#{File.read(path)}")
      command = "gpg --batch -v --import \"#{path}\""
      run(command) do |stdin, output, handle|
        extract_recipients(output)
      end
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

    def decrypt_file(path, data_output_path, passphrase=nil)
      passphrase ||= ''
      command_pieces = [
          'gpg',
          '--quiet',
          '--batch',
          pinentry_mode_command_options(passphrase),
          passphrase_command_options(passphrase),
          '--yes',
          '--ignore-mdc-error',
          '--output',
          "\"#{data_output_path}\"",
          '--decrypt',
          "\"#{path}\""
      ]
      command = command_pieces.reject(&:empty?).join(' ')
      run_gpg_silent_command(command)
    end

    def sign_file(path, data_output_path, passphrase=nil)
      passphrase ||= ''
      command_pieces = [
          'gpg',
          '--quiet',
          '--batch',
          pinentry_mode_command_options(passphrase),
          passphrase_command_options(passphrase),
          '--yes',
          '--ignore-mdc-error',
          '--output',
          "\"#{data_output_path}\"",
          '--sign',
          "\"#{path}\""
      ]
      command = command_pieces.reject(&:empty?).join(' ')
      run_gpg_silent_command(command)
    end

    def encrypt_file(path, data_output_path, recipients, options)
      recipients_str = recipients
                           .map { |s| "--recipient \"#{s}\"" }
                           .join(' ')
      options_str = options.join(' ')
      command = "gpg #{options_str} --quiet --batch --yes --output \"#{data_output_path}\" #{recipients_str} --trust-model always --encrypt \"#{path}\""
      run_gpg_silent_command(command)
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

    def extract_recipients(str)
      (str || '')
          .lines
          .map { |l| l.scan(/\<(.+)\>/m) }
          .flatten
          .reject(&:empty?)
          .uniq
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

    def passphrase_command_options(passphrase)
      return '' if passphrase.empty?

      "--passphrase \"#{passphrase}\""
    end

    def pinentry_mode_command_options(passphrase)
      return '' if passphrase.empty?
      return '' if version_default.start_with?('2.0.')

      '--pinentry-mode loopback'
    end
  end
end
