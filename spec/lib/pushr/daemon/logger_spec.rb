require 'spec_helper'
require 'pushr/daemon'

describe Pushr::Daemon::Logger do
  describe 'log level' do
    let(:logger) { Pushr::Daemon::Logger.new(foreground: false, error_notification: false) }
    it 'info' do
      expect_any_instance_of(Logger).to receive(:add)
      allow(Logger).to receive(:add)
      logger.info('info')
    end

    it 'error' do
      expect_any_instance_of(Logger).to receive(:add)
      allow(Logger).to receive(:add)
      logger.error('error')
    end

    it 'warn' do
      expect_any_instance_of(Logger).to receive(:add)
      allow(Logger).to receive(:add)
      logger.warn('warn')
    end
  end
end
