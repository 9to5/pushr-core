class Logger
  attr_reader :log
  attr_accessor :level, :formatter
  def initialize(file)
    @log = []
  end

  def add(level, msg)
    puts formatter.call(level, Time.now, 'Pushr', msg)
  end
end
