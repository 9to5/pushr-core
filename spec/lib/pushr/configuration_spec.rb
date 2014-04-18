require 'spec_helper'

describe Pushr::Configuration do

  before(:each) do
    Pushr.configure do |config|
      config.redis = ConnectionPool.new(size: 1, timeout: 1) { MockRedis.new }
    end
  end

  describe 'all' do
    it 'returns all configurations' do
      expect(Pushr::Configuration.all).to eql([])
    end
  end

  describe 'create' do
    it 'should create a configuration' do
      config = Pushr::ConfigurationDummy.new(app: 'app_name', connections: 2, enabled: true)
      expect(config.key).to eql('app_name:dummy')
    end
  end

  describe 'save' do
    let(:config) { Pushr::ConfigurationDummy.new(app: 'app_name', connections: 2, enabled: true) }
    let(:config_invalid) { Pushr::ConfigurationDummy.new }
    it 'should return true' do
      expect(config.save).to be_true
    end

    it 'should return false' do
      expect(config_invalid.save).to be_false
    end

    it 'should save a configuration' do
      config.save
      expect(Pushr::Configuration.all.count).to eql(1)
    end
  end

  describe 'find' do
    let!(:config) { Pushr::ConfigurationDummy.new(app: 'app_name', connections: 2, enabled: true) }
    it 'should find a configuration' do
      config.save
      expect(Pushr::Configuration.find(config.key)).to be_kind_of(Pushr::ConfigurationDummy)
    end
  end

  describe 'delete' do
    let!(:config) { Pushr::ConfigurationDummy.new(app: 'app_name', connections: 2, enabled: true) }
    it 'should remove a configuration' do
      config.save
      expect(Pushr::Configuration.all.count).to eql(1)
      config.delete
      expect(Pushr::Configuration.all.count).to eql(0)
    end
  end
end
