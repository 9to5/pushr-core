require 'active_model'
require 'pushr/version'
require 'pushr/configuration'
require 'pushr/message'
require 'pushr/feedback'
require 'pushr/redis_connection'

module Pushr
  NAME = "Pushr"
  DEFAULTS = { }

  def self.options
    @options ||= DEFAULTS.dup
  end

  def self.options=(opts)
    @options = opts
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
    raise ArgumentError, "requires a block" if !block
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
      raise ArgumentError, "redis= requires a Hash or ConnectionPool"
    end
  end

  # instruments with a block
  def self.instrument(name, payload={}, &block)
    ActiveSupport::Notifications.instrument(name, payload) do
      yield
    end
  end
end