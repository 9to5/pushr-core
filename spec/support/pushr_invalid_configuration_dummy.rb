module Pushr
  class InvalidConfigurationDummy < Pushr::Configuration
    attr_accessor :id, :type, :app, :enabled, :connections, :test_attr
    def name
      :invalid_dummy
    end

    def to_hash
      { type: self.class.to_s, app: app, enabled: enabled, connections: connections, test_attr: test_attr }
    end
  end
end
