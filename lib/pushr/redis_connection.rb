require 'connection_pool'
require 'redis'
require 'redis/namespace'

module Pushr
  class RedisConnection
    def self.create(options = {})
      namespace = options[:namespace] || Pushr::Core.options[:namespace]

      ConnectionPool.new(timeout: options[:timeout] || 1, size: options[:size] || 5) do
        client = Redis.connect(options)

        if namespace
          Redis::Namespace.new(namespace, redis: client)
        else
          client
        end
      end
    end
  end
end
