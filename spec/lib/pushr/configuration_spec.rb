require 'spec_helper'

describe Pushr::Configuration do

  before(:each) do
    Pushr::Core.configure do |config|
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
      expect(config.save).to eql true
    end

    it 'should return false' do
      expect(config_invalid.save).to eql false
    end

    it 'should save a configuration' do
      config.save
      expect(Pushr::Configuration.all.count).to eql(1)
    end
  end

  describe 'create' do
    subject { Pushr::ConfigurationDummy.create(app: 'app_name', connections: 2, enabled: true) }
    it 'should create a message' do
      expect(subject.valid?).to eql true
    end

    it 'should create a ConfigurationDummy class' do
      expect(subject.class).to eql Pushr::ConfigurationDummy
    end
  end

  describe 'create!' do
    subject { Pushr::ConfigurationDummy.create!(app: app_name, connections: 2, enabled: true) }

    context 'with app name' do
      let(:app_name) { 'app_name' }
      it 'should create a message' do
        expect(subject.valid?).to eql true
      end

      it 'should create a ConfigurationDummy class' do
        expect(subject.class).to eql Pushr::ConfigurationDummy
      end
    end

    context 'without app name' do
      let(:app_name) { nil }
      it 'should raise error' do
        expect { subject }.to raise_error Pushr::Error::RecordInvalid
      end
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
