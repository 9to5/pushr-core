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

      def pid_file=(file)
        @pid_file = Pathname.new(file).absolute? ? file : File.join(Dir.pwd, file)
      end
    end
  end
end
