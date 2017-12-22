require 'thread'
require 'logger'
require 'multi_json'
require 'pushr/redis_connection'
require 'pushr/daemon/settings'
require 'pushr/daemon/delivery_error'
require 'pushr/daemon/message_handler'
require 'pushr/daemon/feedback_handler'
require 'pushr/daemon/logger'
require 'pushr/daemon/app'
require 'pushr/daemon/pid_file'

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

      start_app

      logger.info('[Daemon] Ready')

      sleep 1 until @shutting_down
    end

    protected

    def self.start_app
      load_stats_processor
      App.load
      scale_redis_connections
      App.start
      self.feedback_handler = FeedbackHandler.new(config.feedback_processor)
      feedback_handler.start
    end

    def self.scale_redis_connections
      # feedback handler + app + app.totalconnections
      connections = 1 + 1 + App.total_connections
      Pushr::Core.configure do |config|
        config.redis = if Pushr::Core.configuration_json
          ::MultiJson.load(Pushr::Core.configuration_json, :symbolize_keys => true)[:redis].merge(size: connections)
        else
          { size: connections }
        end
      end
    end

    def self.load_stats_processor
      require "#{Dir.pwd}/#{config.stats_processor}" if config.stats_processor
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
      PidFile.delete(config.pid_file)
    end

    def self.daemonize
      exit if fork
      Process.setsid
      exit if fork

      Dir.chdir '/'
      File.umask 0000

      STDIN.reopen '/dev/null'
      STDOUT.reopen '/dev/null', 'a'
      STDERR.reopen STDOUT
      PidFile.write(config.pid_file)
    end
  end
end
