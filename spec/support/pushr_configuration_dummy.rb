module Pushr
  class ConfigurationDummy < Pushr::Configuration
    attr_accessor :test_attr

    def name
      :dummy
    end

    def to_hash(_ = nil)
      { id: [@app, name].join(':'), type: self.class.to_s, app: app, enabled: enabled, connections: connections, test_attr: test_attr }
    end
  end
end
