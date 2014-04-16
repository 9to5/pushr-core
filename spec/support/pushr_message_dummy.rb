module Pushr
  class MessageDummy < Pushr::Message
    POSTFIX = 'dummy'
    attr_accessor :postfix, :type, :app, :device

    def to_message
    end

    def to_json(args = nil)
      MultiJson.dump(type: self.class.to_s, app: app, device: device)
    end
  end
end
