require "logger"

class Object
  @@logger = nil
  def logger
    unless @@logger
      @@logger = Logger.new(STDERR)
      @@logger.level = Logger::DEBUG
    end
    @@logger
  end
end