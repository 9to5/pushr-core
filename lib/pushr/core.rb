require 'yaml'
require 'active_model'
require 'multi_json'
require 'pushr/version'
require 'pushr/configuration'
require 'pushr/message'
require 'pushr/feedback'
require 'pushr/redis_connection'

module Pushr

  module Core
    class ConfigurationError; end

    NAME = 'Pushr'
    DEFAULTS = {}

    attr_writer :options

    @@external_id_tag = 'external_id'
    @@configuration_file = nil

    def self.external_id_tag=(value)
      @@external_id_tag = value
    end

    def self.external_id_tag
      @@external_id_tag
    end

    def self.configuration_file=(filename)
      if filename
      filename = File.join(Dir.pwd,filename) if ! Pathname.new(filename).absolute?
      if File.file?(filename)
        @@configuration_file = filename
      else
        raise ConfigurationError.new("config file does not exist: #{filename}")
      end
    end

    def self.configuration_file
      @@configuration_file
    end

    def self.options
      @options ||= DEFAULTS.dup
    end

    ##
    # Configuration for Pushr, use like:
    #
    #   Pushr.configure do |config|
    #     config.redis = { :namespace => 'myapp', :size => 1, :url => 'redis://myhost:8877/mydb' }
    #   end
    def self.configure
      yield self
    end

    def self.redis(&block)
      fail ArgumentError, 'requires a block' unless block
      @redis ||= Pushr::RedisConnection.create
      @redis.with(&block)
    end

    def self.redis=(hash)
      if hash.is_a?(Hash)
        @redis = RedisConnection.create(hash)
        options[:namespace] ||= hash[:namespace]
      elsif hash.is_a?(ConnectionPool)
        @redis = hash
      else
        fail ArgumentError, 'redis= requires a Hash or ConnectionPool'
      end
    end

    # instruments with a block
    def self.instrument(name, payload = {}, &block)
      ActiveSupport::Notifications.instrument(name, payload) do
        yield
      end
    end
  end
end
