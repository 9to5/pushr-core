require 'spec_helper'
require 'pushr/daemon'

describe Pushr::Daemon::Settings do
  describe 'log level' do
    subject { Pushr::Daemon::Settings.new }

    it 'returns absolute path' do
      subject.pid_file = __FILE__
      expect(subject.pid_file).to eql __FILE__
    end

    it 'returns relative path' do
      subject.pid_file = 'filename.pid'
      expect(subject.pid_file).to eql File.join(Dir.pwd, 'filename.pid')
    end

    it 'returns nil if no pid_file' do
      expect(subject.pid_file).to eql nil
    end
  end
end
