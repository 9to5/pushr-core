require 'spec_helper'

describe Pushr::Feedback do

  before(:each) do
    Pushr::Core.configure do |config|
      config.redis = ConnectionPool.new(size: 1, timeout: 1) { MockRedis.new }
    end
  end

  describe 'save' do
    let(:feedback) { Pushr::FeedbackDummy.new(app: 'app_name', device: 'a' * 64, follow_up: 'delete', failed_at: Time.now) }
    let(:feedback_invalid) { Pushr::FeedbackDummy.new }
    it 'should return true' do
      expect(feedback.save).to eql true
    end

    it 'should return false' do
      expect(feedback_invalid.save).to eql false
    end

    it 'should save a feedback' do
      feedback.save
      expect(Pushr::Feedback.next).to be_kind_of(Pushr::FeedbackDummy)
    end
  end

  describe 'create' do
    subject { Pushr::FeedbackDummy.create(app: 'app_name', device: 'a' * 64, follow_up: 'delete', failed_at: Time.now) }
    it 'should create a message' do
      expect(subject.valid?).to eql true
    end

    it 'should create a FeedbackDummy class' do
      expect(subject.class).to eql Pushr::FeedbackDummy
    end
  end

  describe 'create!' do
    subject { Pushr::FeedbackDummy.create!(app: app_name, device: 'a' * 64, follow_up: 'delete', failed_at: Time.now) }

    context 'with app name' do
      let(:app_name) { 'app_name' }
      it 'should create a message' do
        expect(subject.valid?).to eql true
      end

      it 'should create a FeedbackDummy class' do
        expect(subject.class).to eql Pushr::FeedbackDummy
      end
    end

    context 'without app name' do
      let(:app_name) { nil }
      it 'should raise error' do
        expect { subject }.to raise_error Pushr::Error::RecordInvalid
      end
    end
  end
end
