module Pushr
  class InvalidConfigurationDummy < Pushr::Configuration
    attr_accessor :id, :type, :app, :enabled, :connections, :test_attr
    def name
      :invalid_dummy
    end
  end
end
