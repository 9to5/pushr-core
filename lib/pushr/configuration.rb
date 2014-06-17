module Pushr
  class Configuration
    include ActiveModel::Validations

    attr_accessor :id, :type, :app, :enabled, :connections
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

    def to_json
      MultiJson.dump(to_hash)
    end

    def self.all
      if Pushr::Core.configuration_file # only set if file exists
        read_from_yaml_file
      else
        read_from_redis
      end
    end

    def self.find(key)
      config = Pushr::Core.redis { |conn| conn.hget('pushr:configurations', key) }
      instantiate_json(config, key)
    end

    def self.read_from_yaml_file
      filename = Pushr::Core.configuration_file
      configs = File.open(filename) { |fd| YAML.load(fd) }
      configs.map { |hsh| instantiate(hsh) }
    end

    def self.read_from_redis
      configurations = Pushr::Core.redis { |conn| conn.hgetall('pushr:configurations') }
      configurations.each { |key, config| configurations[key] = instantiate_json(config, key) }
      configurations.values
    end

    def self.instantiate_json(config, id)
      instantiate(::MultiJson.load(config).merge!(id: id))
    end

    def self.instantiate(hsh)
      klass = hsh['type'].split('::').reduce(Object) { |a, e| a.const_get e }
      klass.new(hsh)
    end
  end
end
