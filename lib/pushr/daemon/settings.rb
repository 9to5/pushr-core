module Pushr
  module Daemon
    class Settings
      attr_reader :pid_file, :configuration_file
      attr_accessor :foreground, :error_notification, :feedback_processor, :stats_processor

      def initialize
        @foreground = false
        @error_notification = false
        @feedback_processor = nil
        @stats_processor = nil
        @pid_file = nil
        @configuration_file = nil
      end

      def pid_file=(arg)
        @pid_file = File.join(Dir.pwd, arg) if arg && !Pathname.new(arg).absolute?
      end

      def configuration_file=(filename)
        if filename
          filename = File.join(Dir.pwd,filename) if ! Pathname.new(filename).absolute?
          if File.file?(filename)
            @configuration_file = filename
          else
            Pushr::Daemon.logger.error("can not find config file: #{filename}")
          end
        end
      end

      def configurations
        if configuration_file
          configs = File.open(configuration_file) { |fd| YAML.load(fd) }
          configs.each do |klass_name,hash|
            klass = Kernel.const_get(klass_name)

            hash.each do |app,settings_hash|
              settings_hash['app'] = app
              # if a certificate is mentioned in the YAML file, treat it as a filename, and load the Certificate
              if settings_hash['certificate']
                filename = settings_hash['certificate']
                if ! Pathname.new(filename).absolute?
                  filename = File.join(  defined?(Rails) && !Rails.root.nil? ? Rails.root : Dir.pwd , filename)
                end
                settings_hash['certificate'] = File.read( filename )
              end
              # instanciate the new Pushr::Configuration (sub-)class:
              klass.new(settings_hash)
            end
          end
          Pushr::Daemon.logger.info("read config file: #{configuration_file}")
        else
          # read persisted configurations from Redis:
          Pushr::Configuration.all
        end
      end

    end
  end
end
