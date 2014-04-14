require 'spec_helper'

describe Pushr::Message do

  before(:each) do
    Pushr.configure do |config|
      config.redis = ConnectionPool.new(size: 1, timeout: 1) { MockRedis.new }
    end
  end

  describe 'next' do
    it 'returns next message' do
      expect(Pushr::Message.next('pushr:app_name:dummy')).to eql(nil)
    end
  end

  describe 'next' do
    let(:message) { Pushr::MessageDummy.new(app: 'app_name', device: 'test') }
    it 'should save a message' do
      message.save
      expect(Pushr::Message.next('pushr:app_name:dummy')).to be_kind_of(Pushr::MessageDummy)
    end
  end
end
