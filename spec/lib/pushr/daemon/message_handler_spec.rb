require 'spec_helper'
require 'pushr/daemon'

describe Pushr::Daemon::MessageHandler do

  before(:each) do
    Pushr::Core.configure do |config|
      config.redis = ConnectionPool.new(size: 1, timeout: 1) { MockRedis.new }
    end

    logger = double('logger')
    allow(logger).to receive(:info)
    allow(logger).to receive(:error)
    allow(logger).to receive(:warn)
    Pushr::Daemon.logger = logger
  end

  describe 'delivers message' do
    let(:message) { Pushr::MessageDummy.new(app: 'app_name', device: 'test') }
    let(:config) { Pushr::ConfigurationDummy.new(app: 'app_name', connections: 2, enabled: true) }
    let(:connection) { Pushr::Daemon::DummySupport::ConnectionDummy.new(config, 1) }
    it 'should start' do
      message.save
      connection.connect
      handler = Pushr::Daemon::MessageHandler.new('pushr:app_name:dummy', connection, 'app', 1)
      handler.stop
      thread = handler.start
      thread.join
      expect(connection.data.to_json).to eql(message.to_json)
    end
  end

  describe 'fails' do
    let(:message) { Pushr::MessageDummy.new(app: 'app_name', device: 'test') }
    let(:config) { Pushr::ConfigurationDummy.new(app: 'app_name', connections: 2, enabled: true) }
    let(:connection) { Pushr::Daemon::DummySupport::ConnectionDummy.new(config, 1) }
    let(:error) { Pushr::Daemon::DeliveryError.new('100', message, 'desc', 'source', false) }
    it 'should start' do
      expect_any_instance_of(Pushr::Daemon::DummySupport::ConnectionDummy).to receive(:write).and_raise(error)
      message.save
      connection.connect
      handler = Pushr::Daemon::MessageHandler.new('pushr:app_name:dummy', connection, 'app', 1)
      handler.stop
      thread = handler.start
      thread.join
    end
  end
end
