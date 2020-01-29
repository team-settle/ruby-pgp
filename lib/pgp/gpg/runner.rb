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

    def add_keys(key_data)
    #  TODO
    end

    def verify(signed_data)
    #  TODO
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