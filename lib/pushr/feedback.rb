module Pushr
  class Feedback
    include ActiveModel::Validations

    attr_accessor :type, :app
    validates :app, presence: true
    validates :device, presence: true
    validates :follow_up, presence: true
    validates :failed_at, presence: true

    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value) if respond_to?("#{name}=")
      end
    end

    def save
      if valid?
        Pushr::Core.redis { |conn| conn.rpush('pushr:feedback', to_json) }
        return true
      else
        return false
      end
    end

    def to_json
      MultiJson.dump(to_hash)
    end

    def self.next(timeout = 3)
      Pushr::Core.redis do |conn|
        feedback = conn.blpop('pushr:feedback', timeout: timeout)
        return instantiate(feedback[1]) if feedback
      end
    end

    def self.instantiate(config)
      hsh = ::MultiJson.load(config)
      klass = hsh['type'].split('::').reduce(Object) { |a, e| a.const_get e }
      klass.new(hsh)
    end
  end
end
