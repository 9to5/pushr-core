module Pushr
  class Message
    include ActiveModel::Validations

    validates :app, presence: true

    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end

    def save
      if valid?
        Pushr.redis { |conn| conn.rpush("pushr:#{app}:#{self.class::POSTFIX}", to_json) }
      else
        return false
      end
    end

    def self.next(queue_name, timeout = 3)
      Pushr.redis do |conn|
        message = conn.blpop(queue_name, timeout)
        return instantiate(message[1]) if message
      end
    end

    def self.instantiate(message)
      return nil unless message
      hsh = ::MultiJson.load(message)
      klass = hsh['type'].split('::').reduce(Object) { |a, e| a.const_get e }
      klass.new(hsh)
    end
  end
end
