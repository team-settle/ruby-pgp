module GPGME
  class VersionHelper
    def self.switch_to_gpg1
      runner = GPG::Runner.new
      if runner.should_switch_to_gpg1?
        bin = runner.binary_path_gpg1
        home_dir = GPGME::Engine.dirinfo('homedir')
        GPGME::Engine.set_info(GPGME::PROTOCOL_OpenPGP, bin, home_dir)
      end
    end
  end
end