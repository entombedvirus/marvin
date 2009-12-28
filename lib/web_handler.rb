require 'evma_httpserver'
require 'cgi'

module Marvin
  module WebHandler
    include EventMachine::HttpServer

    def initialize(bot)
      @bot = bot
    end

    def process_http_request
      operation = proc { send_without_gist }

      # Callback block to execute once the request is fulfilled
      callback = proc do |res|
        resp = EventMachine::DelegatedHttpResponse.new(self)
        resp.status = 200
        resp.content = "Payload deployed!"
        resp.send_response
      end

      # Let the thread pool (20 Ruby threads) handle request
      EM.defer(operation, callback)
    end
    
    def send_without_gist
      msg = []
      
      msg << if rand(42).zero? 
        "NUCLEAR LAUNCH DETECTED!\n" 
      else 
        "%s deploy by %s detected.\n" % [
          app_name, 
          params["deployer"]
        ]
      end
      
      msg << "Changelog\n-------------\n"
      msg << CGI.unescape(@http_post_content.to_s)
      
      @bot.send_message(msg.join("\n"))
    end
    
    def app_name
      if params["app_name"]
        params["app_name"].first
      else
        "Unknown App"
      end
    end
    
    def params
      @params ||= CGI.parse(@http_query_string.to_s)
    end
  end
end