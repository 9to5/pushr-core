require 'thread'
require 'logger'
require 'multi_json'
require 'pushr/redis_connection'
require 'pushr/daemon/delivery_error'
require 'pushr/daemon/delivery_handler'
require 'pushr/daemon/feedback_handler'
require 'pushr/daemon/logger'
require 'pushr/daemon/app'

module Pushr
  module Daemon
    class << self
      attr_accessor :logger, :config, :feedback_handler
    end

    def self.start(config)
      self.config = config
      self.logger = Logger.new(foreground: config.foreground, error_notification: config.error_notification)
      setup_signal_hooks

      daemonize unless config.foreground
      write_pid_file

      load_stats_processor

      App.load
      scale_redis_connections
      App.start
      self.feedback_handler = FeedbackHandler.new(config.feedback_processor)
      feedback_handler.start

      logger.info('[Daemon] Ready')
      while !@shutting_down
        sleep 1
      end
    end

    protected

    def self.scale_redis_connections
      # feedback handler + app + app.totalconnections
      connections = 1 + 1 + App.total_connections
      Pushr::Core.configure do |config|
        config.redis = { size: connections }
      end
    end

    def self.load_stats_processor
      if config.stats_processor
        require "#{Dir.pwd}/#{config.stats_processor}"
      end
    rescue => e
      logger.error("Failed to stats_processor: #{e.inspect}")
    end

    def self.setup_signal_hooks
      @shutting_down = false

      %w(SIGINT SIGTERM).each do |signal|
        Signal.trap(signal) do
          handle_shutdown_signal
        end
      end
    end

    def self.handle_shutdown_signal
      exit 1 if @shutting_down
      @shutting_down = true
      shutdown
    end

    def self.shutdown
      print "\nShutting down..."
      feedback_handler.stop
      App.stop

      while Thread.list.count > 1
        sleep 0.1
        print '.'
      end
      print "\n"
      delete_pid_file
    end

    def self.daemonize
      exit if pid = fork
      Process.setsid
      exit if pid = fork

      Dir.chdir '/'
      File.umask 0000

      STDIN.reopen '/dev/null'
      STDOUT.reopen '/dev/null', 'a'
      STDERR.reopen STDOUT
    end

    def self.write_pid_file
      unless config[:pid_file].blank?
        begin
          File.open(config[:pid_file], 'w') do |f|
            f.puts $PROCESS_ID
          end
        rescue SystemCallError => e
          logger.error("Failed to write PID to '#{config[:pid_file]}': #{e.inspect}")
        end
      end
    end

    def self.delete_pid_file
      pid_file = config[:pid_file]
      File.delete(pid_file) if !pid_file.blank? && File.exist?(pid_file)
    end
  end
end
