require 'open3'

module GPG
  class Runner
    attr_accessor :verbose

    def initialize(verbose = false)
      self.verbose = verbose
    end

    # @deprecated this method will go away once we stop using gpgme
    def default_gpg_is_v2?
      version_default.start_with? '2.'
    end

    # @deprecated this method will go away once we stop using gpgme
    def default_gpg_is_v1?
      version_default.start_with? '1.'
    end

    def version_default
      read_version('gpg --version', '')
    end

    # @deprecated this method will go away once we stop using gpgme
    def version_gpg1
      read_version('gpg1 --version', '')
    end

    # @deprecated this method will go away once we stop using gpgme
    def should_switch_to_gpg1?
      if default_gpg_is_v1?
        false
      else
        !version_gpg1.empty?
      end
    end

    # @deprecated this method will go away once we stop using gpgme
    def binary_path_gpg1
      run('which gpg1') do |stdin, output, handle|
        return '' unless handle.value.success?
        output.gets.lines.first.strip
      end
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
      run_gpg_silent_command("gpg --quiet --batch --import #{path}")
    end

    def verify_signature_file(path)
      run_gpg_silent_command("gpg --quiet --batch --verify #{path}")
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
      if verbose
        PGP::Log.logger.info("Running Command: #{command}")
      end

      Open3.popen2e(command) do |stdin, output, handle|
        if verbose
          PGP::Log.logger.info("Output:\n#{output.gets}")
          PGP::Log.logger.info("Success?: #{handle.value.success?}")
        end

        yield(stdin, output, handle)
      end
    end
  end
end