require 'spec_helper'
require 'pushr/daemon'

describe Pushr::Daemon::Logger do
  describe 'logger' do
    it 'should log to file' do
      log = File.join(Dir.pwd, 'log', 'pushr.log')
      File.stub(open: log)
      FileUtils.stub(mkdir_p: nil)
      log.should_receive(:sync=).with(true)
      logger = Pushr::Daemon::Logger.new(foreground: false, error_notification: false)
      logger.info('test')
    end

    it 'should log to STDOUT' do
      STDOUT.stub(:puts)
      logger = Pushr::Daemon::Logger.new(foreground: false, error_notification: false)
      logger.info('test')
    end
  end

  describe 'log level' do
    let(:logger) { Pushr::Daemon::Logger.new(foreground: false, error_notification: false) }
    it 'info' do
      Logger.any_instance.should_receive(:add)
      Logger.stub(:add)
      logger.info('info')
    end

    it 'error' do
      Logger.any_instance.should_receive(:add)
      Logger.stub(:add)
      logger.error('error')
    end

    it 'warn' do
      Logger.any_instance.should_receive(:add)
      Logger.stub(:add)
      logger.warn('warn')
    end
  end
end
