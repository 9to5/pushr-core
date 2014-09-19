require 'yaml'
require 'active_model'
require 'multi_json'
require 'pushr/version'
require 'pushr/error'
require 'pushr/configuration'
require 'pushr/message'
require 'pushr/feedback'
require 'pushr/redis_connection'

module Pushr
  module Core
    NAME = 'Pushr'
    DEFAULTS = { external_id_tag: 'external_id' }

    attr_writer :options

    def self.options
      @options ||= DEFAULTS.dup
    end

    ##
    # Configuration for Pushr, use like:
    #
    #   Pushr::Core.configure do |config|
    #     config.redis = { namespace: 'myapp', url: 'redis://myhost:8877/mydb' }
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
        options.merge!(hash)
        @redis = RedisConnection.create(options)
      elsif hash.is_a?(ConnectionPool)
        @redis = hash
      else
        fail ArgumentError, 'redis= requires a Hash or ConnectionPool'
      end
    end

    def self.external_id_tag=(value)
      options[:external_id_tag] = value
    end

    def self.external_id_tag
      options[:external_id_tag]
    end

    def self.configuration_file
      options[:configuration_file]
    end

    def self.configuration_file=(filename)
      if filename
        filename = File.join(Dir.pwd, filename) unless Pathname.new(filename).absolute?
        if File.file?(filename)
          options[:configuration_file] = filename
        else
          fail ArgumentError, "can not find config file: #{filename}"
        end
      end
    end

    # instruments with a block
    def self.instrument(name, payload = {})
      ActiveSupport::Notifications.instrument(name, payload) do
        yield
      end
    end
  end
end
