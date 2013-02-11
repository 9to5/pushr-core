module Pushr
  class Feedback
    include ActiveModel::Validations
    validates :app, :presence => true
    validates :device, :presence => true
    validates :follow_up, :presence => true
    validates :failed_at, :presence => true

    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end

    def save
      Pushr::Daemon.redis { |conn| conn.rpush('pushr:feedback', self.to_json) }
    end
  end
end