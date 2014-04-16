require 'spec_helper'
require 'pushr/daemon'

describe Pushr::Daemon::FeedbackHandler do

  before(:each) do
    Pushr.configure do |config|
      config.redis = ConnectionPool.new(size: 1, timeout: 1) { MockRedis.new }
    end
    Pushr::Daemon.logger = Pushr::Daemon::Logger.new(foreground: true, error_notification: false)
  end

  describe 'start' do
    let(:feedback) { Pushr::FeedbackDummy.new(app: 'app_name', device: 'test') }
    it 'should start' do
      Pushr::FeedbackProcessor.any_instance.should_receive(:process)
      feedback.save
      handler = Pushr::Daemon::FeedbackHandler.new('spec/support/pushr_feedback_processor_dummy')
      handler.stop
      thread = handler.start
      thread.join
    end
  end

  describe 'fails' do
    let(:feedback) { Pushr::FeedbackDummy.new(app: 'app_name', device: 'test') }
    let(:error) { StandardError.new('test') }
    it 'should start' do
      Pushr::FeedbackProcessor.any_instance.stub(:process).and_raise(error)
      feedback.save
      handler = Pushr::Daemon::FeedbackHandler.new('spec/support/pushr_feedback_processor_dummy')
      handler.stop
      thread = handler.start
      thread.join
    end
  end
end
