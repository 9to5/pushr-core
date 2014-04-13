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
      Pushr.redis { |conn| conn.hset('pushr:configurations', "#{self.app}:#{self.name}", self.to_json) }
    end

    def self.all
      configurations = Pushr.redis { |conn| conn.hgetall("pushr:configurations") }
      configurations.each { |key,config| configurations[key] = instantiate(config, key) }
      configurations.values
    end

    def self.find(key)
      config = Pushr.redis { |conn| conn.hget("pushr:configurations", key) }
      instantiate(config, key)
    end

    def self.delete(key)
      Pushr.redis { |conn| conn.hdel("pushr:configurations", key) }
    end

    def self.instantiate(config, id)
      hsh = ::MultiJson.load(config).merge!({id: id})
      require "#{hsh["gem"]}"
      klass = hsh["type"].split('::').inject(Object) {|parent, klass| parent.const_get klass}
      klass.new(hsh)
    end
  end
end