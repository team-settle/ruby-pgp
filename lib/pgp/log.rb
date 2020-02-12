require 'logger'

module PGP
  class Log
    class << self
      attr_writer :logger
      attr_writer :verbose

      def logger
        @logger ||= Logger.new($stdout).tap do |log|
          log.progname = self.name
        end
      end

      def verbose
        @verbose ||= false
      end
    end
  end

  module LogCapable
    def log(message)
      if PGP::Log.verbose
        PGP::Log.logger.info(message)
      end
    end
  end
end