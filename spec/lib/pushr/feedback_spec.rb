require 'spec_helper'

describe Pushr::Feedback do

  before(:each) do
    Pushr.configure do |config|
      config.redis = ConnectionPool.new(size: 1, timeout: 1) { MockRedis.new }
    end
  end

  describe 'save' do
    let(:feedback) { Pushr::FeedbackDummy.new(app: 'app_name', device: 'a' * 64, follow_up: 'delete', failed_at: Time.now) }
    let(:feedback_invalid) { Pushr::FeedbackDummy.new }
    it 'should return true' do
      expect(feedback.save).to be_true
    end

    it 'should return false' do
      expect(feedback_invalid.save).to be_false
    end

    it 'should save a feedback' do
      feedback.save
      expect(Pushr::Feedback.next).to be_kind_of(Pushr::FeedbackDummy)
    end
  end
end
