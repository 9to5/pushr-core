module Pushr
  module Daemon
    class Settings
      attr_reader :pid_file, :configuration_path
      attr_accessor :foreground, :error_notification, :feedback_processor, :stats_processor

      def initialize
        @foreground = false
        @error_notification = false
        @feedback_processor = nil
        @stats_processor = nil
        @pid_file = nil
        @configuration_path = nil
      end

      def pid_file=(arg)
        @pid_file = File.join(Dir.pwd, arg) if arg && !Pathname.new(arg).absolute?
      end

      def configuration_path=(arg)
        @configuration_path = File.join(Dir.pwd, arg) if arg && !Pathname.new(arg).absolute?
      end

      def configurations
        if configuration_path
          configs = File.open('config.yml') { |fd| YAML.load(fd) }
          configs.map do |hsh|
            klass = hsh['type'].split('::').reduce(Object) { |a, e| a.const_get e }
            klass.new(hsh)
          end
        else
          Pushr::Configuration.all
        end
      end
    end
  end
end
