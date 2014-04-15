module Pushr
  module Daemon
    module DummySupport
      class ConnectionDummy
        attr_reader :name, :configuration
        attr_accessor :data

        def initialize(configuration, i)
          @configuration = configuration
          @name = "#{@configuration.app}: ConnectionGcm #{i}"
        end

        def connect
        end

        def write(data)
          self.data = data
        end

        def check_for_error(notification)
        end
      end
    end
  end
end
