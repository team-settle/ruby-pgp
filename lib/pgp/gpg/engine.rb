module GPG
  class Engine
    attr_accessor :runner

    def initialize(runner = nil)
      self.runner = runner || GPG::Runner.new
    end

    def delete_all_keys
      delete_all_private_keys
      delete_all_public_keys
    end

    def delete_all_private_keys
      runner.read_private_key_fingerprints.each do |k|
        runner.delete_private_key k
      end
    end

    def delete_all_public_keys
      runner.read_public_key_fingerprints.each do |k|
        runner.delete_public_key k
      end
    end
  end
end