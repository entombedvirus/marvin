require 'xmpp4r-simple'
require 'eventmachine'

require "lib/jabber_bot"
require "lib/command_processor"
require "lib/web_handler"

module Marvin
  extend self
  
  def start(options)
    EM.run do      
      marvin = Marvin::JabberBot.new(*options.values_at(:jabber_server, :username, :passwd))
      
      # Start the web listener
      EM.start_server("0.0.0.0", 9090, WebHandler, marvin)
    end
  end
end

