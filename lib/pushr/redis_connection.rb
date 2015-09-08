require 'connection_pool'
require 'redis'
require 'redis/namespace'

module Pushr
  class RedisConnection
    def self.create(options = {})
      namespace = options[:namespace] || Pushr::Core.options[:namespace]

      config = {
        url: options[:url] || 'redis://master',
        sentinels: options[:sentinels] || [],
      }

      ConnectionPool.new(timeout: options[:timeout] || 1, size: options[:size] || 5) do
        client = Redis.connect(config)

        if namespace
          Redis::Namespace.new(namespace, redis: client)
        else
          client
        end
      end
    end
  end
end
