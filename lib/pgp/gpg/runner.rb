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
        extract_fingerprints(output)
      end
    end

    def read_key_fingerprints
      Open3.popen2e('gpg --quiet --list-keys --fingerprint') do |stdin, output, handle|
        return [] unless handle.value.success?
        extract_fingerprints(output)
      end
    end

    def delete_private_key(fingerprint)
      command = "gpg --quiet --batch --delete-secret-key #{fingerprint}"
      Open3.popen2e(command) do |stdin, output, handle|
        handle.value.success?
      end
    end

    def delete_key(fingerprint)
      command = "gpg --quiet --batch --delete-key #{fingerprint}"
      Open3.popen2e(command) do |stdin, output, handle|
        handle.value.success?
      end
    end

    def delete_all_private_keys
      read_private_key_fingerprints.each do |k|
        delete_private_key k
      end
    end

    def delete_all_keys
      read_key_fingerprints.each do |k|
        delete_key k
      end
    end

    private

    def read_version(command, default_value)
      Open3.popen2e(command) do |stdin, output, handle|
        return default_value unless handle.value.success?
        output.gets.lines.first.split(' ').last.strip
      end
    end

    def extract_fingerprints(output)
      output
          .gets
          .lines
          .filter { |l| l.downcase.include? 'key fingerprint =' }
          .map { |l| l.split('=').last }
          .map { |l| l.gsub(' ', '').strip }
    end
  end
end