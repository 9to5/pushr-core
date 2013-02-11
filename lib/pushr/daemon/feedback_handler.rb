module Pushr
  module Daemon
    class FeedbackHandler
      attr_reader :name, :processor, :processor_path

      def initialize(processor_path)
        @name = "FeedbackHandler"
        @processor_path = processor_path
      end

      def start
        return unless @processor_path
        require "#{Dir.pwd}/#{@processor_path}"
        @processor = Pushr::FeedbackProcessor.new

        @thread = Thread.new do
          loop do
            break if @stop
            handle_next_feedback
          end
        end
      end

      def stop
        @stop = true
      end

      protected

      def handle_next_feedback
        feedback = nil
        result = Pushr::Daemon.redis { |conn| conn.blpop('push:feedback', :timeout => 3) }

        unless result == nil
          hsh = MultiJson.load(result[1])
          obj = hsh['type'].split('::').inject(Object) {|parent, klass| parent.const_get klass}
          feedback = obj.new(hsh)
        end

        @processor.process(feedback) if feedback
      rescue StandardError => e
        Pushr::Daemon.logger.error(e)
      end
    end
  end
end