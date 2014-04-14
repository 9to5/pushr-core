module Pushr
  class Feedback
    include ActiveModel::Validations
    validates :app, presence: true
    validates :device, presence: true
    validates :follow_up, presence: true
    validates :failed_at, presence: true

    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end

    def save
      Pushr.redis { |conn| conn.rpush('pushr:feedback', to_json) }
    end

    def self.next(timeout = 3)
      Pushr.redis do |conn|
        feedback = conn.blpop('pushr:feedback', timeout)
        if feedback
          return instantiate(feedback[1])
        end
      end
    end

    private

    def self.instantiate(config)
      hsh = ::MultiJson.load(config)
      klass = hsh['type'].split('::').reduce(Object) { |parent, klass| parent.const_get klass }
      klass.new(hsh)
    end
  end
end
