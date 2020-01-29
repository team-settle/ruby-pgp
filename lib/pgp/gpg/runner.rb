require 'open3'

module GPG
  class Runner
    def is_gpg2?
      version.start_with? '2.'
    end

    def is_gpg1?
      version.start_with? '1.'
    end

    def version
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