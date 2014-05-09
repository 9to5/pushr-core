module Pushr
  module Daemon
    class PidFile
      def self.write(pid_file)
        unless pid_file.nil?
          begin
            File.open(pid_file, 'w') do |f|
              f.puts Process.pid
            end
          rescue SystemCallError => e
            logger.error("Failed to write PID to '#{pid_file}': #{e.inspect}")
          end
        end
      end

      def self.delete(pid_file)
        File.delete(pid_file) if !pid_file.blank? && File.exist?(pid_file)
      end
    end
  end
end
