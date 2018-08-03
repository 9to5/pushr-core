module Pushr
  module Daemon
    class Logger
      def initialize(options)
        @options = options

        if @options[:foreground]
          STDOUT.sync = true
          @logger = ::Logger.new(STDOUT)
        else
          log_dir = File.join(Dir.pwd, 'log')
          FileUtils.mkdir_p(log_dir)
          log = File.open(File.join(log_dir, 'pushr.log'), 'a')
          log.sync = true
          @logger = ::Logger.new(log)
        end

        @logger.level = ::Logger::INFO
        @logger.formatter = proc do |severity, datetime, progname, msg|
          "[#{datetime}] #{severity}: #{msg}\n"
        end
      end

      def info(msg)
        log(::Logger::INFO, msg)
      end

      def error(msg)
        error_notification(msg)
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

      def error_notification(e)
        if do_error_notification?(e) && defined?(Airbrake)
          Airbrake.notify(e)
        end
      end

      def do_error_notification?(e)
        @options[:error_notification] && ((e.is_a?(DeliveryError) && e.notify) || e.is_a?(Exception))
      end
    end
  end
end
