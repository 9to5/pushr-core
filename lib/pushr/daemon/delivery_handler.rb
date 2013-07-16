module Pushr
  module Daemon
    class DeliveryHandler
      attr_reader :name

      def initialize(queue_name, connection, name, i)
        @queue_name = queue_name
        @connection = connection
        @name = "#{name}: DeliveryHandler #{i}"
        Pushr::Daemon.logger.info "[#{@name}] listening to #{@queue_name}"
      end

      def start
        @thread = Thread.new do
          loop do
            break if @stop
            handle_next_notification
          end
        end
      end

      def stop
        @stop = true
      end

      protected

      def handle_next_notification
        notification = nil
        result = Pushr.redis { |conn| conn.blpop(@queue_name, :timeout => 3) }

        unless result == nil
          hsh = MultiJson.load(result[1])
          obj = hsh['type'].split('::').inject(Object) {|parent, klass| parent.const_get klass}
          notification = obj.new(hsh)

          if notification
            puts notification.inspect
            Pushr.instrument('message',{app: notification.app, type: notification.type}) do
              @connection.write(notification.to_message)
              @connection.check_for_error(notification)
              Pushr::Daemon.logger.info("[#{@connection.name}] Message delivered to #{notification.device}")
            end
          end
        end
      rescue DeliveryError => e
        Pushr::Daemon.logger.error(e, {:error_notification => e.notify})
      rescue StandardError => e
        Pushr::Daemon.logger.error(e)
      end
    end
  end
end