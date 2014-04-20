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
        Thread.new do
          loop do
            handle_next
            break if @stop
          end
        end
      end

      def stop
        @stop = true
      end

      protected

      def handle_next
        message = Pushr::Message.next(@queue_name)
        return if message.nil?

        Pushr.instrument('message', app: message.app, type: message.type) do
          @connection.write(message)
          Pushr::Daemon.logger.info("[#{@connection.name}] Message delivered to #{message.device}")
        end
      rescue => e
        Pushr::Daemon.logger.error(e)
      end
    end
  end
end
