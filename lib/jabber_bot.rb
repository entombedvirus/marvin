require 'thread'

module Marvin
  class JabberBot
    attr_reader :jabber
    
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
        @jabber.received_messages {|m| process_command(m)}
      end
    end
    
    def process_command(message)
      # c = CommandProcessor.new(message)
      # 
      # c.callback do
      #   next unless c.response
      #   @jabber.deliver(message.from, c.response)
      # end
      # 
      # c.errback do
      #   @jabber.deliver(message.from, "does not compute!")
      # end
      # 
      # Thread.new { c.process! }
      case message.body
      when "!deploy"
        update_code!(message)
      else
        @jabber.deliver(message.from, "Dunno wachu talkin abt.")
      end
    end
    
    def send_message(msg)
      @mutex.synchronize do
        @jabber.deliver(@config["target_contact"], msg)
      end
    end
    
    def update_code!(message)
      deploy_handler = Module.new do
        def initialize(bot, target_contact)
          @bot = bot
          @target_contact = target_contact
        end
        
        # Let bluepill restart marvin
        def unbind
          @bot.jabber.deliver(@target_contact, @data)
          EM.stop_event_loop
        end
        
        def receive_data(data)
          @data ||= ""
          @data << data
        end
      end
      
      EM.popen("git pull", deploy_handler, self, message.from)
    end
  end
end