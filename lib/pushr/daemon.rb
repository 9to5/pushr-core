require 'thread'
require 'redis'
require 'connection_pool'
require 'multi_json'
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
      self.logger = Logger.new(:foreground => config.foreground, :error_notification => config.error_notification)
      setup_signal_hooks

      unless config.foreground
        daemonize
        reconnect_database
      end
      write_pid_file

      App.load
      App.start
      self.feedback_handler = FeedbackHandler.new(config.feedback_processor)
      self.feedback_handler.start

      logger.info('[Daemon] Ready')
      while (!@shutting_down)
        sleep 1
      end
    end

    def self.redis(&block)
      raise ArgumentError, "requires a block" if !block
      @redis ||= ConnectionPool.new(:size => 5, :timeout => 3) { Redis.connect }
      @redis.with(&block)
    end

    protected

    def self.setup_signal_hooks
      @shutting_down = false

      ['SIGINT', 'SIGTERM'].each do |signal|
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
      self.feedback_handler.stop
      App.stop

      while Thread.list.count > 1
        sleep 0.1
        print "."
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
      if !config[:pid_file].blank?
        begin
          File.open(config[:pid_file], 'w') do |f|
            f.puts $$
          end
        rescue SystemCallError => e
          logger.error("Failed to write PID to '#{config[:pid_file]}': #{e.inspect}")
        end
      end
    end

    def self.delete_pid_file
      pid_file = config[:pid_file]
      File.delete(pid_file) if !pid_file.blank? && File.exists?(pid_file)
    end
  end
end