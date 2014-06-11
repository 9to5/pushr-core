require 'spec_helper'
require 'pushr/daemon'

describe Pushr::Daemon::App do

  before(:each) do
    Pushr::Core.configure do |config|
      config.redis = ConnectionPool.new(size: 1, timeout: 1) { MockRedis.new }
    end

    logger = double('logger')
    allow(logger).to receive(:info)
    allow(logger).to receive(:error)
    allow(logger).to receive(:warn)
    Pushr::Daemon.logger = logger
    Pushr::Daemon.config = settings
  end

  let(:settings) { Pushr::Daemon::Settings.new }
  let(:config) { Pushr::ConfigurationDummy.new(app: 'app_name', connections: 1, enabled: true) }
  describe 'self' do
    before(:each) do
      config.save
      Pushr::Daemon::App.load
    end

    it 'should load show total_connections' do
      expect(Pushr::Daemon::App.total_connections).to eql(1)
    end

    it 'should load app' do
      expect(Pushr::Daemon::App.apps.count).to eql(1)
    end

    it 'should start/stop app' do
      Pushr::Daemon::App.start
      Pushr::Daemon::App.stop
    end
  end

  describe 'class' do
    it 'should start configuration' do
      expect_any_instance_of(Pushr::Daemon::MessageHandler).to receive(:start)
      config.save
      app = Pushr::Daemon::App.new(config)
      app.start
      app.stop
    end

    it 'should not start configuration' do
      config = Pushr::InvalidConfigurationDummy.new(app: 'app_name', connections: 2, enabled: true)
      config.save
      app = Pushr::Daemon::App.new(config)
      expect { app.start }.to raise_error(LoadError)
    end
  end
end
