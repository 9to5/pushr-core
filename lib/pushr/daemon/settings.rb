module Pushr
  module Daemon
    class Settings
      attr_accessor :foreground, :pid_file, :error_notification, :feedback_processor, :stats_processor

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
    end
  end
end
