class ::Logger
  def initialize(file)
  end

  @@log = []

  def self.info(message)
    @@log.push(message)
  end

  def add(level, msg)
    puts "#{level}: #{msg}"
  end

  def self.log
    @@log
  end
end
