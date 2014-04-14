module Pushr
  class ConfigurationDummy < Pushr::Configuration
    attr_accessor :id, :gem, :type, :app, :enabled, :connections, :test_attr

    def name
      :dummy
    end

    def to_json(args = nil)
      hsh = {
        id: [@app, name].join(':'),
        gem: 'pushr-dummy',
        type: self.class.to_s,
        app: app,
        enabled: enabled,
        connections: connections,
        test_attr: test_attr
      }

      ::MultiJson.dump(hsh)
    end
  end
end
