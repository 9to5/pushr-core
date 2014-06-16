module Pushr
  module Daemon
    class App
      @apps = []

      class << self
        attr_reader :apps

        def load
          @apps = Pushr::Configuration.all.keep_if { |c| c.enabled == true }.map { |c| App.new(c) }
        end

        def total_connections
          @apps.map(&:connections).inject(0, :+)
        end

        def start
          @apps.map(&:start)
        end

        def stop
          @apps.map(&:stop)
        end
      end

      def initialize(config)
        @config = config
        @handlers = []
        @provider = nil
      end

      def connections
        @config.connections
      end

      def start
        @provider = load_provider(@config.name, @config)
        @provider.start
      end

      def stop
        @provider.stop
      end

      protected

      def load_provider(klass, options)
        begin
          middleware = Pushr::Daemon.const_get("#{klass}".camelize)
        rescue NameError
          message = "Could not find matching push provider for #{klass.inspect}. " \
                    "You may need to install an additional gem (such as pushr-#{klass})."
          raise LoadError, message
        end

        middleware.new(options)
      end
    end
  end
end
