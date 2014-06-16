module Pushr
  module Daemon
    class Settings
      attr_reader :pid_file
      attr_accessor :foreground, :error_notification, :feedback_processor, :stats_processor

      def initialize
        @foreground = false
        @error_notification = false
        @feedback_processor = nil
        @stats_processor = nil
        @pid_file = nil
      end

      def pid_file=(arg)
        @pid_file = File.join(Dir.pwd, arg) if arg && !Pathname.new(arg).absolute?
      end

      def configuration_file(filename)
        Pushr::Core.configuration_file = filename
      end

      def configuration_file
        Pushr::Core.configuration_file
      end
    end
  end
end
