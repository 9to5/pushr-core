require 'spec_helper'
require 'pushr/daemon'

describe Pushr::Daemon::DeliveryHandler do

  before(:each) do
    Pushr.configure do |config|
      config.redis = ConnectionPool.new(size: 1, timeout: 1) { MockRedis.new }
    end
    Pushr::Daemon.logger = Pushr::Daemon::Logger.new(foreground: true, error_notification: false)
  end

  describe 'delivers message' do
    let(:message) { Pushr::MessageDummy.new(app: 'app_name', device: 'test') }
    let(:config) { Pushr::ConfigurationDummy.new(app: 'app_name', connections: 2, enabled: true) }
    let(:connection) { Pushr::Daemon::DummySupport::ConnectionDummy.new(config, 1) }
    it 'should start' do
      message.save
      connection.connect
      handler = Pushr::Daemon::DeliveryHandler.new('pushr:app_name:dummy', connection, 'app', 1)
      handler.stop
      thread = handler.start
      thread.join
      connection.data.to_json.should eql(message.to_json)
    end
  end

  describe 'fails' do
    let(:message) { Pushr::MessageDummy.new(app: 'app_name', device: 'test') }
    let(:config) { Pushr::ConfigurationDummy.new(app: 'app_name', connections: 2, enabled: true) }
    let(:connection) { Pushr::Daemon::DummySupport::ConnectionDummy.new(config, 1) }
    let(:error) { Pushr::Daemon::DeliveryError.new('100', message, 'desc', 'source', false) }
    it 'should start' do
      Pushr::Daemon::DummySupport::ConnectionDummy.any_instance.stub(:check_for_error).and_raise(error)
      message.save
      connection.connect
      handler = Pushr::Daemon::DeliveryHandler.new('pushr:app_name:dummy', connection, 'app', 1)
      handler.stop
      thread = handler.start
      thread.join
    end
  end
end
