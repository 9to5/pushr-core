module Pushr
  class Configuration
    include ActiveModel::Validations
    validates :app, presence: true
    validates :connections, presence: true
    validates :connections, numericality: { greater_than: 0, only_integer: true }
    validates :enabled, inclusion: { in: [true, false] }

    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value) if respond_to?("#{name}=")
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
      if Pushr::Daemon.config.configuration_file # only set if file exists
        read_from_yaml_file
      else
        read_from_redis
      end
    end

    def self.find(key)
      config = Pushr::Core.redis { |conn| conn.hget('pushr:configurations', key) }
      instantiate(config, key)
    end

    def to_json
      MultiJson.dump(to_hash)
    end

    private

    def read_from_yaml_file
      filename = Pushr::Daemon.config.configuration_file
      configs = File.open(filename) { |fd| YAML.load(fd) }
      configs.map do |hsh|
        klass = hsh['type'].split('::').reduce(Object) { |a, e| a.const_get e }
        klass.new(hsh)
      end
    end

    def read_from_redis
      configurations = Pushr::Core.redis { |conn| conn.hgetall('pushr:configurations') }
      configurations.each { |key, config| configurations[key] = instantiate(config, key) }
      configurations.values
    end

    def self.instantiate(config, id)
      hsh = ::MultiJson.load(config).merge!(id: id)
      klass = hsh['type'].split('::').reduce(Object) { |a, e| a.const_get e }
      klass.new(hsh)
    end
  end
end
