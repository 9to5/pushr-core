module Pushr
  class FeedbackDummy < Pushr::Feedback
    attr_accessor :device, :follow_up, :failed_at
    validates :device, format: { with: /\A[a-z0-9]{64}\z/ }
    validates :follow_up, inclusion: { in: %w(delete), message: '%{value} is not a valid follow-up' }

    def to_hash(_ = nil)
      { type: 'Pushr::FeedbackDummy', app: app, device: device, follow_up: follow_up, failed_at: failed_at }
    end
  end
end
