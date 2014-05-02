require 'spec_helper'
require 'pushr/daemon'

describe Pushr::Daemon::FeedbackHandler do

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

  describe 'start' do
    let(:feedback) { Pushr::FeedbackDummy.new(app: 'app_name', device: 'a' * 64, failed_at: Time.now, follow_up: 'delete') }
    it 'should start' do
      expect_any_instance_of(Pushr::FeedbackProcessor).to receive(:process)
      feedback.save
      handler = Pushr::Daemon::FeedbackHandler.new('spec/support/pushr_feedback_processor_dummy')
      handler.stop
      thread = handler.start
      thread.join
    end
  end

  describe 'fails' do
    let(:feedback) { Pushr::FeedbackDummy.new(app: 'app_name', device: 'a' * 64, failed_at: Time.now, follow_up: 'delete') }
    let(:error) { StandardError.new('test') }
    it 'should start' do
      expect_any_instance_of(Pushr::FeedbackProcessor).to receive(:process).and_raise(error)
      feedback.save
      handler = Pushr::Daemon::FeedbackHandler.new('spec/support/pushr_feedback_processor_dummy')
      handler.stop
      thread = handler.start
      thread.join
    end
  end
end
