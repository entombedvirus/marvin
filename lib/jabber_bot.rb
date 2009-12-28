require 'thread'

module Marvin
  class JabberBot
    def initialize(config)
      @config = config.dup
      
      username, passwd = config.values_at("username", "passwd")
      @jabber = Jabber::Simple.new(username, passwd, nil, "Marvin is active! =)")
      
      at_exit{@jabber.status(:away, "marvin is feeling down")}
      
      @mutex = Mutex.new
      
      start_throwing_away_incoming_messages
    end

    def start_throwing_away_incoming_messages
      EM::PeriodicTimer.new(1) do
        @jabber.received_messages {|m| }
      end
    end
    
    # def start
    #   # EM::PeriodicTimer.new(1) do
    #   #   @jabber.received_messages do |message|
    #   #     process_command(message)
    #   #   end
    #   # end
    # end
    # 
    # def process_command(message)
    #   c = CommandProcessor.new(message)
    #   
    #   c.callback do
    #     next unless c.response
    #     @jabber.deliver(message.from, c.response)
    #   end
    #   
    #   c.errback do
    #     @jabber.deliver(message.from, "does not compute!")
    #   end
    #   
    #   Thread.new { c.process! }
    # end
    
    def send_message(msg)
      @mutex.synchronize do
        @jabber.deliver(@config["target_contact"], msg)
      end
    end
  end
end