module Pushr
  module Daemon
    class Dummy
      attr_accessor :configuration
      def initialize(options)
        self.configuration = options
      end

      def connectiontype
        DummySupport::ConnectionDummy
      end

      def stop; end
    end
  end
end
