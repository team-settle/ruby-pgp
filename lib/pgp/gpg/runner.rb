require 'open3'

module GPG
  class Runner
    def default_gpg_is_v2?
      version_default.start_with? '2.'
    end

    def default_gpg_is_v1?
      version_default.start_with? '1.'
    end

    def version_default
      read_version('gpg --version', '')
    end

    def version_gpg1
      read_version('gpg1 --version', '')
    end

    def should_switch_to_gpg1?
      if default_gpg_is_v1?
        false
      else
        !version_gpg1.empty?
      end
    end

    def binary_path_gpg1
      Open3.popen2e('which gpg1') do |stdin, output, handle|
        return '' unless handle.value.success?
        output.gets.lines.first.strip
      end
    end

    def read_private_key_fingerprints
      Open3.popen2e('gpg --quiet --list-secret-keys --fingerprint') do |stdin, output, handle|
        return [] unless handle.value.success?
        output
            .gets
            .lines
            .filter { |l| l.downcase.include? 'key fingerprint =' }
            .map { |l| l.split('=').last }
            .map { |l| l.gsub(' ', '').strip }
      end
    end

    private

    def read_version(command, default_value)
      Open3.popen2e(command) do |stdin, output, handle|
        return default_value unless handle.value.success?
        output.gets.lines.first.split(' ').last.strip
      end
    end
  end
end