module Marvin
  class CommandProcessor
    include EM::Deferrable
    
    def initialize(message)
      @message = message
    end
    
    def process!
      succeed unless processable_command?
      
      # simulate doing stuff
      sleep 5
      
      succeed
    end
    
    def processable_command?
      true
    end
    
    def response
      @message.body.length
    end
  end
end