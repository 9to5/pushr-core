module Pushr
  class Configuration
    include ActiveModel::Validations
    @@configurations = []

    validates :app, presence: true
    validates :connections, presence: true
    validates :connections, numericality: { greater_than: 0, only_integer: true }
    validates :enabled, inclusion: { in: [true, false] }

    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value) if respond_to?("#{name}=")
      end
      @@configurations << self
      self
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
      return @@configurations if ! @@configurations.empty? # in case somebody calls this when using a YAML file

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

    def to_json
      MultiJson.dump(to_hash)
    end
  end
end
