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
end