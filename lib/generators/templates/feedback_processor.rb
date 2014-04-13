module Pushr
  class FeedbackProcessor
    def initialize
      # make sure you've set the RAILS_ENV variable
      load 'config/environment.rb'
    end

    def process(feedback)
      if feedback.instance_of? Pushr::FeedbackGcm
        if feedback.follow_up == 'delete'
          # TODO: delete gcm device
          Pushr::Daemon.logger.info('[FeedbackProcessor] Pushr::FeedbackGcm delete')
        elsif feedback.follow_up == 'update'
          # TODO: update gcm device
          # device = feedback.update_to
          Pushr::Daemon.logger.info('[FeedbackProcessor] Pushr::FeedbackGcm update')
        end
      elsif feedback.instance_of? Pushr::FeedbackC2dm
        if feedback.follow_up == 'delete'
          # TODO: delete c2dm device
          Pushr::Daemon.logger.info('[FeedbackProcessor] Pushr::FeedbackC2dm delete')
        end
      elsif feedback.instance_of? Pushr::FeedbackApns
        if feedback.follow_up == 'delete'
          # TODO: delete apns device
          Pushr::Daemon.logger.info('[FeedbackProcessor] Pushr::FeedbackApns delete')
        end
      else
        Pushr::Daemon.logger.info('[FeedbackProcessor] Unknown feedback type')
      end
    end
  end
end
