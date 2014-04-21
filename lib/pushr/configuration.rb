module Pushr
  class Configuration
    include ActiveModel::Validations

    validates :app, presence: true
    validates :connections, presence: true
    validates :connections, numericality: { greater_than: 0, only_integer: true }

    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end

    def key
      "#{app}:#{name}"
    end

    def save
      if valid?
        Pushr::Core.redis { |conn| conn.hset('pushr:configurations', key, to_json) }
        return true
      else
        return false
      end
    end

    def delete
      Pushr::Core.redis { |conn| conn.hdel('pushr:configurations', key) }
    end

    def self.all
      configurations = Pushr::Core.redis { |conn| conn.hgetall('pushr:configurations') }
      configurations.each { |key, config| configurations[key] = instantiate(config, key) }
      configurations.values
    end

    def self.find(key)
      config = Pushr::Core.redis { |conn| conn.hget('pushr:configurations', key) }
      instantiate(config, key)
    end

    def self.instantiate(config, id)
      hsh = ::MultiJson.load(config).merge!(id: id)
      klass = hsh['type'].split('::').reduce(Object) { |a, e| a.const_get e }
      klass.new(hsh)
    end
  end
end
