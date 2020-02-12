module PGP
  module LogHelper
    def log(message)
      if PGP::Log.verbose
        PGP::Log.logger.info(message)
      end
    end
  end
end