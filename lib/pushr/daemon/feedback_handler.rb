module Pushr
  module Daemon
    class FeedbackHandler
      attr_reader :name, :processor, :processor_path

      def initialize(processor_path)
        @name = 'FeedbackHandler'
        @processor_path = processor_path
      end

      def start
        return unless @processor_path
        require "#{Dir.pwd}/#{@processor_path}"
        @processor = Pushr::FeedbackProcessor.new

        @thread = Thread.new do
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
        feedback = Pushr::Feedback.next
        @processor.process(feedback) if feedback
      rescue => e
        Pushr::Daemon.logger.error(e)
      end
    end
  end
end
