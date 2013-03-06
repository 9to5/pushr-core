module Pushr
  module Daemon
    class App
      class << self
        attr_reader :apps
      end

      @apps = {}

      def self.load
        configurations = Pushr.redis { |conn| conn.hvals('pushr:configurations') }
        configurations.each do |config|
          hsh = ::MultiJson.load(config)
          require "#{hsh["gem"]}"
          klass = hsh["type"].split('::').inject(Object) {|parent, klass| parent.const_get klass}
          obj = klass.new(hsh)

          @apps["#{obj.app}:#{obj.name}"] = App.new(obj) if obj.enabled == true
        end
      end

      def self.total_connections
        @apps.values.map(&:connections).inject(0, :+)
      end

      def self.start
        @apps.values.map(&:start)
      end

      def self.stop
        @apps.values.map(&:stop)
      end

      def initialize(config)
        @config = config
        @handlers = []
        @provider = nil
        @connection = nil
      end

      def connections
        @config.connections
      end

      def start
        @provider = load_provider(@config.name, @config)

        @config.connections.times do |i|
          @connection = @provider.connectiontype.new(@config, i+1)
          @connection.connect

          handler = DeliveryHandler.new("pushr:#{@config.app}:#{@config.name}", @connection, @config.app, i+1)
          handler.start
          @handlers << handler
        end
      end

      def stop
        @handlers.map(&:stop)
        @provider.stop
      end

      protected

      def load_provider(klass, options)
        begin
          middleware = Pushr::Daemon.const_get("#{klass}".camelize)
        rescue NameError
          raise LoadError, "Could not find matching push provider for #{klass.inspect}. You may need to install an additional gem (such as push-#{klass})."
        end

        middleware.new(options)
      end
    end
  end
end