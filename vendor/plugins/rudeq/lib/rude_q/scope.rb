require File.dirname(__FILE__) + "/../rude_q"

module RudeQ
  class Scope

    def initialize(queue_name)
      @queue_name = queue_name
    end
    attr_reader :queue_name

    def set(data)
      RudeQueue.set(self.queue_name, data)
    end

    def get()
      RudeQueue.get(self.queue_name)
    end

    def backlog()
      RudeQueue.backlog(self.queue_name)
    end
  end
end

