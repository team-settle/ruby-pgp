require 'open3'

module GPG
  class Runner
    def version
      Open3.popen2e('gpg --version') do |stdin, output, handle|
        return '' unless handle.value.success?

        full_version_info = output.gets
        version_number = full_version_info.lines.first.split(' ').last
        return version_number
      end
    end

    def add_keys(key_data)
    #  TODO
    end

    def verify(signed_data)
    #  TODO
    end
  end
end