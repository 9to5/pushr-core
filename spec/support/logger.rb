class ::Logger
  attr_reader :log
  def initialize(file)
    @log = []
  end

  def self.info(message)
    @log.push(message)
  end

  def add(level, msg)
    puts "#{level}: #{msg}"
  end
end
