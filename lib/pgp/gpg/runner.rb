require 'open3'

module GPG
  class Runner
    def is_gpg2?
      version.start_with? '2.'
    end

    def version
      Open3.popen2e('gpg --version') do |stdin, output, handle|
        return '' unless handle.value.success?

        output.gets.lines.first.split(' ').last
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