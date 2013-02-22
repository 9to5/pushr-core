module Pushr
  module Daemon
    class Logger
      def initialize(options)
        @options = options

        if @options[:foreground]
          @logger = ::Logger.new(STDOUT)
        else
          @logger = ::Logger.new(File.join(Dir.pwd, 'log', 'pushr.log'))
        end

        @logger.level = ::Logger::INFO
        @logger.formatter = proc do |severity, datetime, progname, msg|
          "[#{datetime}] #{severity}: #{msg}\n"
        end
      end

      def info(msg)
        log(::Logger::INFO, msg)
      end

      def error(msg, options = {})
        error_notification(msg, options)
        log(::Logger::ERROR, msg, 'ERROR')
      end

      def warn(msg)
        log(::Logger::WARN, msg, 'WARNING')
      end

      private

      def log(level, msg, prefix = nil)
        if msg.is_a?(Exception)
          msg = "#{msg.class.name}, #{msg.message}: #{msg.backtrace.join("\n") if msg.backtrace}"
        end
        @logger.add(level, msg)
      end

      def error_notification(e, options)
        return unless do_error_notification?(e, options)
        Airbrake.notify_or_ignore(e) if defined?(Airbrake)
      end

      def do_error_notification?(msg, options)
        @options[:error_notification] and options[:error_notification] != false and msg.is_a?(Exception)
      end
    end
  end
end