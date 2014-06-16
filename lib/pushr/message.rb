module Pushr
  class Message
    include ActiveModel::Validations

    attr_accessor :type, :app, :external_id
    validates :app, presence: true

    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value) if respond_to?("#{name}=")
      end
    end

    def save
      if valid?
        Pushr::Core.redis { |conn| conn.rpush("pushr:#{app}:#{self.class::POSTFIX}", to_json) }
        return true
      else
        return false
      end
    end

    def to_json
      MultiJson.dump(to_hash)
    end

    def self.next(queue_name, timeout = 3)
      Pushr::Core.redis do |conn|
        message = conn.blpop(queue_name, timeout: timeout)
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
