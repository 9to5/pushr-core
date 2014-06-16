module Pushr
  class MessageDummy < Pushr::Message
    POSTFIX = 'dummy'
    attr_accessor :device_id

    def to_message
    end

    def to_hash(_ = nil)
      { type: self.class.to_s, app: app, device_id: device_id }
    end
  end
end
