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
      $pushredis.hset('push:configurations', "#{self.name}:#{self.app}", self.to_json)

    end

    def all
      $pushredis.lrange "push:configurations", 0, -1
    end
  end
end