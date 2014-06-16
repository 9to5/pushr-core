module Pushr
  class MessageDummy < Pushr::Message
    POSTFIX = 'dummy'
    attr_accessor :postfix, :type, :app

    def to_message
    end

    def to_hash(_ = nil)
      { type: self.class.to_s, app: app }
    end
  end
end
