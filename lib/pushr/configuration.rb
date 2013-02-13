module Pushr
  class Configuration
    include ActiveModel::Validations

    validates :app, :presence => true
    validates :connections, :presence => true
    validates :connections, :numericality => { :greater_than => 0, :only_integer => true }

    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end

    def save
      Pushr.redis { |conn| conn.hset('pushr:configurations', "#{self.name}:#{self.app}", self.to_json) }
    end

    def self.all
      Pushr.redis { |conn| conn.hgetall("pushr:configurations") }
    end

    def self.find(key)
      Pushr.redis { |conn| conn.hget("pushr:configurations", key) }
    end

    def self.delete(key)
      Pushr.redis { |conn| conn.hdel("pushr:configurations", key) }
    end
  end
end