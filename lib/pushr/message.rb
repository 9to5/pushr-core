module Pushr
  class Message
    include ActiveModel::Validations

    validates :app, :presence => true
    validates :device, :presence => true

    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end

    def save
      $pushredis.rpush "pushr:#{self.app}:#{self.class::POSTFIX}", self.to_json
    end
  end
end