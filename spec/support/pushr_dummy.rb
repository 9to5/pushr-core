module Pushr
  module Daemon
    class Dummy
      attr_accessor :configuration, :handlers

      def initialize(options)
        @configuration = options
        @handlers = []
      end

      def start
        configuration.connections.times do |i|
          connection = DummySupport::ConnectionDummy.new(configuration, i + 1)
          connection.connect

          handler = MessageHandler.new("pushr:#{configuration.key}", connection, configuration.app, i + 1)
          handler.start
          @handlers << handler
        end
      end

      def stop
        @handlers.map(&:stop)
      end
    end
  end
end
