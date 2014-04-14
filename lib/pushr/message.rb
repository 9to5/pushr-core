module Pushr
  class Message
    include ActiveModel::Validations

    validates :app, presence: true
    validates :device, presence: true

    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end

    def save
      Pushr.redis { |conn| conn.rpush("pushr:#{app}:#{self.class::POSTFIX}", to_json) }
    end

    def self.next(queue_name, timeout = 3)
      Pushr.redis do |conn|
        message = conn.blpop(queue_name, timeout)
        if message
          return instantiate(message[1])
        end
      end
    end

    private

    def self.instantiate(message)
      return nil unless message
      hsh = ::MultiJson.load(message)
      klass = hsh['type'].split('::').reduce(Object) { |parent, klass| parent.const_get klass }
      klass.new(hsh)
    end
  end
end
